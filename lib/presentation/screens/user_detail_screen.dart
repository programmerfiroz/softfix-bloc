import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softfix_user/core/services/translations/localization_extension.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../core/utils/constants/dimensions.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/ui_spacer.dart';
import '../../core/widget/custom_base_widget.dart';
import '../../core/widget/custom_button.dart';
import '../../data/models/user_model.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/favorite/favorite_event.dart';
import '../blocs/favorite/favorite_state.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return CustomBaseWidget(
      showAppBar: true,
      showLeadingAction: true,
      appBarTitle: 'User Details'.tr(context),
      actions: [
        Container(
          margin: EdgeInsets.only(right: Dimensions.width20),
          child: BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              final isFavorite = state.isFavorite(user.id);
              return GestureDetector(
                onTap: () {
                  context.read<FavoriteBloc>().add(
                    ToggleFavoriteEvent(user.id),
                  );

                  CustomSnackbar.showFavoriteStatus(isFavorite: isFavorite);
                },
                child: Container(
                  padding: EdgeInsets.all(Dimensions.width10),
                  // spacing inside the circle
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFavorite
                        ? theme.colorScheme.error.withOpacity(
                            0.2,
                          ) // light red background
                        : theme.colorScheme.onSurface.withOpacity(
                            0.1,
                          ), // light grey background
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    size: Dimensions.iconSize20,
                  ),
                ),
              );
            },
          ),
        ),
      ],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: Dimensions.radius30,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.name[0].toUpperCase().tr(context),
                          style: TextStyle(
                            fontSize: Dimensions.font28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      UiSpacer.verticalSpace(),
                      Text(
                        user.name.tr(context),
                        style: TextStyle(
                          fontSize: Dimensions.font22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      UiSpacer.verticalSpace(space: Dimensions.width4),
                      Text(
                        '@${user.username}'.tr(context),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        context,
                        icon: Icons.email,
                        title: 'Email'.tr(context),
                        value: user.email.tr(context),
                      ),
                      _buildInfoCard(
                        context,
                        icon: Icons.phone,
                        title: 'Phone'.tr(context),
                        value: user.phone.tr(context),
                      ),
                      _buildInfoCard(
                        context,
                        icon: Icons.language,
                        title: 'Website'.tr(context),
                        value: user.website.tr(context),
                      ),
                      _buildInfoCard(
                        context,
                        icon: Icons.location_on,
                        title: 'Address'.tr(context),
                        value:
                            '${user.address.street}, ${user.address.suite}\n${user.address.city}, ${user.address.zipcode}'
                                .tr(context),
                      ),
                      _buildInfoCard(
                        context,
                        icon: Icons.business,
                        title: 'Company'.tr(context),
                        value:
                            '${user.company.name}\n${user.company.catchPhrase}\n${user.company.bs}'
                                .tr(context),
                      ),
                      UiSpacer.verticalSpace(),
                    ],
                  ),
                ),
                UiSpacer.verticalSpace(space: 150),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  text: "Go Location".tr(context),
                  backgroundColor: Theme.of(context).primaryColor,
                  borderRadius: 20,
                    onPressed: () async {
                      try {
                        String lat = user.address.geo.lat;
                        String lng = user.address.geo.lng;

                        // Try Google Maps app first, fallback to browser
                        final Uri googleMapsUrl = Uri.parse('google.navigation:q=$lat,$lng');
                        final Uri webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

                        if (await canLaunchUrl(webUrl)) {
                          await launchUrl(webUrl);
                        } else if (await canLaunchUrl(googleMapsUrl)) {
                          await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                        } else {
                          CustomSnackbar.showError('Could not launch the map.'.tr(context));
                        }
                      } catch (e) {
                        Logger.e('Error: $e');
                        CustomSnackbar.showError('Could not open the map.'.tr(context));
                      }
                    }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            UiSpacer.horizontalSpace(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.tr(context),
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  UiSpacer.verticalSpace(space: Dimensions.height4),
                  Text(
                    value.tr(context),
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
