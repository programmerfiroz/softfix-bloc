import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softfix_user/core/services/translations/localization_extension.dart';
import '../../core/services/translations/language_bottom_sheet.dart';
import '../../core/theme/theme_selector_widget.dart';
import '../../core/utils/constants/app_constants.dart';
import '../../core/utils/constants/dimensions.dart';
import '../../core/utils/ui_spacer.dart';
import '../../core/widget/custom_base_widget.dart';
import '../../core/widget/custom_empty_widget.dart';
import '../../core/widget/custom_retry_widget.dart';
import '../../core/widget/custom_text_field.dart';
import '../../core/widget/loading_widget.dart';
import '../../routes/route_helper.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/favorite/favorite_event.dart';
import '../widgets/user_card.dart';
import 'favorites_screen.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(FetchUsersEvent());
    context.read<FavoriteBloc>().add(LoadFavoritesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBaseWidget(
      showAppBar: true,
      showLeadingAction: false,
      appBarTitle: 'App name'.tr(context),
      actions: [
        IconButton(
          icon: Icon(Icons.language),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const LanguageBottomSheet(),
            );
          },
        ),
        // theme
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const ThemeSelector(),
            );
          },
          icon: const Icon(Icons.color_lens),
        ),
      ],
      fab: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteHelper.getFavoriteRoute());
        },
        child: const Icon(Icons.favorite),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search by name, email or username'.tr(context),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<UserBloc>().add(
                          const SearchUsersEvent(''),
                        );
                      },
                    )
                  : null,
              borderColor: Colors.grey,
              borderRadius: 12,
              onChanged: (query) {
                context.read<UserBloc>().add(SearchUsersEvent(query));
                setState(() {}); // Refresh UI for suffix icon visibility
              },
            ),
          ),

          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(
                    child: LoadingWidget(type: LoadingType.indicator),
                  );
                } else if (state is UserLoaded) {
                  if (state.filteredUsers.isEmpty) {
                    return Center(
                      child: CustomEmptyWidget(
                        icon: Icons.search_off,
                        message: 'No users found'.tr(context),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<UserBloc>().add(RefreshUsersEvent());
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      itemCount: state.filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = state.filteredUsers[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == state.filteredUsers.length - 1 ? 160.0 : 0, // extra bottom margin for last item
                          ),
                          child: UserCard(
                            user: user,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RouteHelper.getUserDetailsRoute(),
                                arguments: user,
                              );

                            },
                          ),
                        );
                      },
                    ),

                  );
                } else if (state is UserEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: Dimensions.iconSize32,
                          color: Colors.grey[400],
                        ),
                        UiSpacer.verticalSpace(),
                         Text(
                          AppConstants.noDataMessage.tr(context),
                          style: TextStyle(fontSize: Dimensions.font16),
                        ),
                      ],
                    ),
                  );
                } else if (state is UserError) {
                  return Center(
                    child: RetryWidget(
                      message: state.message.tr(context),
                      onRetry: () {
                        context.read<UserBloc>().add(FetchUsersEvent());
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
