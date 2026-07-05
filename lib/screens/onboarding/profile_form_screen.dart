import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/geocoding_service.dart';
import '../../core/network/profile_api.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/driver_vehicle_model.dart';
import '../../models/user_model.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../home/home_screen.dart';

/// Second onboarding step: collects the profile fields common to every
/// role, plus vehicle details when [role] is [UserRole.driver].
class ProfileFormScreen extends StatefulWidget {
  final String token;
  final UserModel user;
  final UserRole role;

  const ProfileFormScreen({
    super.key,
    required this.token,
    required this.user,
    required this.role,
  });

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _fullNameController = TextEditingController(
    text: widget.user.fullName ?? '',
  );
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();

  final _brandModelController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _sizeLabelController = TextEditingController();
  final Set<VehicleAmenity> _amenities = {};

  final _profileApi = ProfileApi();
  bool _isSubmitting = false;

  bool get _isDriver => widget.role == UserRole.driver;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _brandModelController.dispose();
    _colorController.dispose();
    _plateNumberController.dispose();
    _sizeLabelController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  String? _validateAge(String? value) {
    final int? age = int.tryParse(value?.trim() ?? '');
    if (age == null || age < 16 || age > 100) {
      return AppLocalizations.of(context)!.enterValidAge;
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final DriverVehicleModel? vehicle = _isDriver
          ? DriverVehicleModel(
              brandModel: _brandModelController.text.trim(),
              color: _colorController.text.trim(),
              plateNumber: _plateNumberController.text.trim(),
              sizeLabel: _sizeLabelController.text.trim(),
              amenities: _amenities,
            )
          : null;

      double? geocodedLat;
      double? geocodedLng;
      try {
        final candidates = await GeocodingService().search(
          _addressController.text.trim(),
        );
        if (candidates.isNotEmpty) {
          geocodedLat = candidates.first.lat;
          geocodedLng = candidates.first.lng;
        }
      } catch (_) {
        // Non-fatal — submit without coordinates rather than blocking.
      }

      final UserModel savedUser = await _profileApi.saveProfile(
        token: widget.token,
        role: widget.role,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        vehicle: vehicle,
        lat: geocodedLat,
        lng: geocodedLng,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => HomeScreen(token: widget.token, user: savedUser),
        ),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isDriver ? l10n.driverProfileTitle : l10n.shipperProfileTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tellUsAboutYourself, style: textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _fullNameController,
                  label: l10n.fullNameLabel,
                  hint: l10n.fullNameHint,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => _requiredValidator(v, l10n.enterFullName),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _phoneController,
                  label: l10n.phoneNumberLabel,
                  hint: '+998 90 123 45 67',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      _requiredValidator(v, l10n.enterPhoneNumber),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _addressController,
                  label: l10n.homeAddressLabel,
                  hint: 'Tashkent, Chilanzar',
                  prefixIcon: Icons.home_outlined,
                  validator: (v) => _requiredValidator(v, l10n.enterAddress),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _ageController,
                  label: l10n.ageLabel,
                  hint: '29',
                  prefixIcon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: _isDriver
                      ? TextInputAction.next
                      : TextInputAction.done,
                  validator: _validateAge,
                ),
                if (_isDriver) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(l10n.vehicleInfo, style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _brandModelController,
                    label: l10n.brandModelLabel,
                    hint: 'Isuzu NPR',
                    prefixIcon: Icons.local_shipping_outlined,
                    validator: (v) =>
                        _requiredValidator(v, l10n.enterBrandModel),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _colorController,
                    label: l10n.colorLabel,
                    hint: l10n.colorHintExample,
                    prefixIcon: Icons.palette_outlined,
                    validator: (v) => _requiredValidator(v, l10n.enterColor),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _plateNumberController,
                    label: l10n.plateNumberLabel,
                    hint: '01 A 123 BC',
                    prefixIcon: Icons.pin_outlined,
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) =>
                        _requiredValidator(v, l10n.enterPlateNumber),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _sizeLabelController,
                    label: l10n.sizeCapacityLabel,
                    hint: l10n.sizeCapacityHintExample,
                    prefixIcon: Icons.straighten_outlined,
                    textInputAction: TextInputAction.done,
                    validator: (v) =>
                        _requiredValidator(v, l10n.enterVehicleSize),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.additionalAmenities, style: textTheme.titleSmall),
                  ...VehicleAmenity.values.map(
                    (amenity) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(amenity.label(l10n), style: textTheme.bodyMedium),
                      value: _amenities.contains(amenity),
                      onChanged: (checked) {
                        setState(() {
                          if (checked ?? false) {
                            _amenities.add(amenity);
                          } else {
                            _amenities.remove(amenity);
                          }
                        });
                      },
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: l10n.saveAndContinue,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
