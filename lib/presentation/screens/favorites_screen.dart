import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softfix_user/core/services/translations/localization_extension.dart';
import '../../core/utils/constants/app_constants.dart';
import '../../core/widget/custom_base_widget.dart';
import '../../core/widget/custom_empty_widget.dart';
import '../../core/widget/loading_widget.dart';
import '../../routes/route_helper.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_state.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/favorite/favorite_state.dart';
import '../widgets/user_card.dart';
import 'user_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomBaseWidget(
      showAppBar: true,
      showLeadingAction: true,
      appBarTitle: 'Favorite Users'.tr(context),

      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoaded) {
            return BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, favoriteState) {
                final favoriteUsers = userState.users
                    .where((user) => favoriteState.isFavorite(user.id))
                    .toList();

                if (favoriteUsers.isEmpty) {
                  return Center(
                    child: CustomEmptyWidget(
                      icon: Icons.favorite_border,
                      message: AppConstants.noFavoritesMessage.tr(context),
                      showBackButton: true,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: favoriteUsers.length,
                  itemBuilder: (context, index) {
                    final user = favoriteUsers[index];

                    EdgeInsets padding = EdgeInsets.only(
                      top: index == 0 ? 16.0 : 0,
                      bottom: index == favoriteUsers.length - 1 ? 160.0 : 0,
                    );

                    return Padding(
                      padding: padding,
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
                );
              },
            );
          } else if (userState is UserLoading) {
            return const Center(
              child: LoadingWidget(type: LoadingType.indicator),
            );
          } else if (userState is UserError) {
            return Center(
              child: CustomEmptyWidget(
                icon: Icons.error_outline,
                message: userState.message.tr(context),
                showBackButton: true,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
