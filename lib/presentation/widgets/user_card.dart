import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softfix_user/core/services/translations/localization_extension.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../data/models/user_model.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/favorite/favorite_event.dart';
import '../blocs/favorite/favorite_state.dart';
import '../../core/utils/constants/dimensions.dart';
import '../../core/utils/ui_spacer.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const UserCard({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.width15,
        vertical: Dimensions.height5,
      ),
      elevation: isDark ? 4 : 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radius12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radius12),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Padding(
          padding: EdgeInsets.all(Dimensions.height10),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: Dimensions.radius25,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  user.name[0].toUpperCase().tr(context),
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              UiSpacer.smallHorizontalSpace(),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      user.name.tr(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    UiSpacer.vSpace(Dimensions.height4),

                    // Email
                    Text(
                      user.email.tr(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: Dimensions.font14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    UiSpacer.vSpace(Dimensions.height4),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: Dimensions.iconSize16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        UiSpacer.hSpace(Dimensions.width4),
                        Expanded(
                          child: Text(
                            '${user.address.city}, ${user.address.street}'.tr(context),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: Dimensions.font14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite Icon
              BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, state) {
                  final isFavorite = state.isFavorite(user.id);
                  return GestureDetector(
                    onTap: (){
                      context.read<FavoriteBloc>().add(
                        ToggleFavoriteEvent(user.id),
                      );

                      CustomSnackbar.showFavoriteStatus(
                        isFavorite: isFavorite,
                      );
                    },
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                      size: Dimensions.iconSize20,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}