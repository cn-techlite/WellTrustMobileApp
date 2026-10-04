// ignore_for_file: prefer_const_constructors, constant_identifier_names, annotate_overrides, overridden_fields, use_key_in_widget_constructors, must_be_immutable

import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import '../../core/utils/colors.dart';

class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchWidget({
    super.key,
    required this.text,
    required this.onChanged,
    required this.hintText,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant SearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text && controller.text != widget.text) {
      controller.text = widget.text;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hintColor = AppColors.muted;

    return SizedBox(
      height: 6.heightAdjusted,
      child: GlobalTextField(
        fieldName: widget.hintText,
        keyBoardType: TextInputType.text,
        textController: controller,
        isOptional: true,
        removeSpace: false,
        maxLength: 100,
        borderRadius: 12,
        prefixIcon: Icon(Icons.search, color: hintColor, size: 24),
        suffix: widget.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  controller.clear();
                  widget.onChanged('');
                  FocusScope.of(context).unfocus();
                },
                icon: Icon(Icons.close, color: hintColor, size: 24),
              )
            : null,
      ),
    );
  }
}

class GlobalTextField extends StatefulWidget {
  final String fieldName;
  final TextInputType keyBoardType;
  final FocusNode? focusNode;
  final TextEditingController textController;
  final int maxLength;
  // final bool isCenterText;
  final bool isEyeVisible;
  final bool removeSpace;
  bool obscureText;
  final bool isOptional;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Widget? prefix;
  final Widget? prefixIcon;
  final Widget? suffix;
  final bool isNotePad;
  final String? confirmPasswordMatch;
  final bool allowDecimal;
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final TextCapitalization? textCapitalization;
  final String? hintText;
  final bool hasError;
  GlobalTextField({
    super.key,
    required this.fieldName,
    required this.keyBoardType,
    required this.textController,
    this.focusNode,
    this.removeSpace = true,
    this.obscureText = false,
    // this.isCenterText = false,
    this.isEyeVisible = false,
    this.isOptional = false,
    this.readOnly = false,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.maxLength = 35,
    this.borderRadius,
    this.onTap,
    this.prefix,
    this.prefixIcon,
    this.suffix,
    this.isNotePad = false,
    this.confirmPasswordMatch,
    this.allowDecimal = false, // 👈 default
    this.enabled = true,
    this.minLines,
    this.maxLines,
    this.textCapitalization,
    this.hintText,
    this.hasError = false,
  });

  @override
  State<GlobalTextField> createState() => _GlobalTextFieldState();
}

class _GlobalTextFieldState extends State<GlobalTextField> {
  late bool _obscureText;
  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    //  TextScaler textScaler = MediaQuery.of(context).textScaler;
    return TextFormField(
      controller: widget.textController,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      obscureText: _obscureText,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      enabled: widget.enabled,
      maxLines: widget.maxLines ?? (widget.isNotePad ? 10 : 1),
      minLines:
          widget.minLines ??
          (widget.isNotePad
              ? widget.maxLength <= 100
                    ? 3
                    : 6
              : 1),
      enableInteractiveSelection: widget.readOnly == true
          ? false
          : true, // prevents long press/double tap menu
      textInputAction: widget.textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      //   textAlign: TextAlign.start,
      textCapitalization:
          widget.textCapitalization ??
          (widget.keyBoardType == TextInputType.name
              ? TextCapitalization.sentences
              : TextCapitalization.none),
      keyboardType: widget.allowDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : widget.obscureText == true
          ? TextInputType.visiblePassword
          : widget.keyBoardType,
      inputFormatters: _buildInputFormatters(),
      style: AppTextType.bodyMedium.style(
        context,
        color: AppColors.black,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.2,
      ),
      decoration: InputDecoration(
        floatingLabelBehavior: widget.hintText == null
            ? FloatingLabelBehavior.never
            : FloatingLabelBehavior.auto,
        labelText: widget.fieldName,
        hintText: widget.hintText,
        isDense: true,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          vertical: 2.heightAdjusted,
          horizontal: 2.widthAdjusted,
        ),
        suffixIcon: widget.isEyeVisible
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.black,
                  size: 25,
                ),
              )
            : widget.suffix,
        prefix: widget.prefix,
        prefixIcon: widget.prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: AppColors.line2, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(
            color: widget.hasError ? AppColors.rose : AppColors.line2,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: AppColors.rose, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(
            color: widget.hasError ? AppColors.rose : AppColors.line2,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(fontSize: 4.textSize, height: 1.1),
      ),

      validator: (value) => _validateField(value),
    );
  }

  List<TextInputFormatter> _buildInputFormatters() {
    List<TextInputFormatter> formatters = [];

    if (widget.removeSpace) {
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s")));
    }

    if (widget.keyBoardType == TextInputType.phone) {
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'^0+')));
    }

    if (widget.allowDecimal) {
      formatters.add(
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
      );
    } else if (widget.keyBoardType == TextInputType.number) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }

    formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));

    return formatters;
  }

  String? _validateField(String? value) {
    if (widget.isOptional && (value == null || value.isEmpty)) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'This input is empty';
    }

    if (widget.obscureText) {
      // Confirm password match check (only for confirm password field)
      if (widget.confirmPasswordMatch != null &&
          value != widget.confirmPasswordMatch) {
        return 'Passwords do not match';
      }
    }

    if (widget.keyBoardType == TextInputType.emailAddress) {
      String trimmed = value.trim();
      if (!EmailValidator.validate(trimmed)) {
        return 'Not a valid email';
      }
    }

    if (widget.keyBoardType == TextInputType.phone && value.length != 10) {
      return 'Phone number must be 10 digits';
    }

    if (widget.allowDecimal) {
      final decimalRegex = RegExp(r'^\d+(\.\d+)?$');
      if (!decimalRegex.hasMatch(value)) {
        return 'Enter a valid amount';
      }
    } else if (widget.keyBoardType == TextInputType.number) {
      if (!RegExp(r'^\d+$').hasMatch(value)) {
        return 'Only numbers allowed';
      }
    }

    return null;
  }
}

class GlobalPhoneTextField extends StatefulWidget {
  final String fieldName;
  final TextEditingController textController;
  final int maxLength;
  final FocusNode? focusNode;
  final Function(MobileNumber?)? onChanged;
  final Function(Country?)? onCountryChanged;
  final double? borderRadius;

  const GlobalPhoneTextField({
    super.key,
    required this.fieldName,
    required this.textController,
    this.maxLength = 35,
    this.focusNode,
    this.onChanged,
    this.onCountryChanged,
    this.borderRadius,
  });

  @override
  State<GlobalPhoneTextField> createState() => _GlobalPhoneTextFieldState();
}

class _GlobalPhoneTextFieldState extends State<GlobalPhoneTextField> {
  @override
  Widget build(BuildContext context) {
    return IntlMobileField(
      controller: widget.textController,
      initialCountryCode: "NG",
      focusNode: widget.focusNode,
      onCountryChanged: widget.onCountryChanged,
      onChanged: widget.onChanged,

      // enabled: true,
      disableLengthCounter: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textAlign: TextAlign.start,
      style: AppTextType.bodyMedium.style(
        context,
        color: AppColors.black,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.2,
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(widget.maxLength)],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
        borderSide: BorderSide(color: AppColors.line2, width: 1.5),
        gapPadding: 40,
      ),

      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: widget.fieldName,
        labelStyle: AppTextType.bodyMedium.style(
          context,
          color: AppColors.black,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.2,
        ),
        isDense: true,

        //  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: EdgeInsets.symmetric(
          vertical: 2.heightAdjusted,
          horizontal: 2.widthAdjusted,
        ),

        // suffixIcon: Icon(Icons.contacts, color: AppColors.black, size: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: AppColors.line2, width: 1.5),
          gapPadding: 40,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: AppColors.line2, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: AppColors.rose, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: AppColors.line2, width: 1.5),
        ),
        errorStyle: TextStyle(fontSize: 4.textSize, height: 1.1),
      ),
      validator: (mobileNumber) {
        if (mobileNumber == null || mobileNumber.number.isEmpty) {
          return 'Please, Enter a mobile number';
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(mobileNumber.number)) {
          return 'Only digits are allowed';
        }
        return null;
      },
    );
  }
}

class SearchableDropdownOption<T> {
  final T value;
  final String label;

  const SearchableDropdownOption({required this.value, required this.label});
}

/// Project-wide searchable dropdown field.
///
/// The user sees an option's [SearchableDropdownOption.label], while
/// [onChanged] receives its typed [SearchableDropdownOption.value]. This lets
/// API-backed forms display a person's name while submitting their id.
class GlobalSearchableDropdown<T> extends StatelessWidget {
  final String title;
  final String hintText;
  final T? value;
  final List<SearchableDropdownOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool showSearch;
  final String emptyMessage;

  const GlobalSearchableDropdown({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hintText = 'Choose',
    this.showSearch = true,
    this.emptyMessage = 'No options are currently available.',
  });

  Future<void> _open(BuildContext context) async {
    final selectedLabel = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomDropdownBottomSheet(
        title: title,
        options: [for (final option in options) option.label],
        showSearch: showSearch,
        emptyMessage: emptyMessage,
      ),
    );
    if (selectedLabel == null) return;

    final selected = options.firstWhere(
      (option) => option.label == selectedLabel,
    );
    onChanged(selected.value);
  }

  @override
  Widget build(BuildContext context) {
    SearchableDropdownOption<T>? selected;
    for (final option in options) {
      if (option.value == value) {
        selected = option;
        break;
      }
    }

    return Semantics(
      button: true,
      label: '$title. Searchable dropdown.',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line2, width: 1.5),
            ),
            child: Row(
              children: [
                if (showSearch) ...[
                  Icon(Icons.search, size: 21, color: AppColors.muted),
                  addHorizontalSpacing(2.56),
                ],
                Expanded(
                  child: AppText(
                    text: selected?.label ?? hintText,
                    type: AppTextType.bodySmall,
                    color: selected == null ? AppColors.muted : AppColors.ink,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                addHorizontalSpacing(2.05),
                Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDropdownBottomSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final bool showSearch;
  final String emptyMessage;

  const CustomDropdownBottomSheet({
    super.key,
    required this.title,
    required this.options,
    this.showSearch = false,
    this.emptyMessage = 'No options are currently available.',
  });

  @override
  State<CustomDropdownBottomSheet> createState() =>
      _CustomDropdownBottomSheetState();
}

class _CustomDropdownBottomSheetState extends State<CustomDropdownBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredOptions = widget.options
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          // color: AppColors.surface,
          height: 50.heightAdjusted,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title + Close Icon
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.heightAdjusted,
                  vertical: 12.widthAdjusted,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: widget.title,
                        type: AppTextType.bodySmall,
                        fontSize: 12.textSize,
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Source Sans 3',
                      ),
                    ),
                    IconButton(
                      color: AppColors.black,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Optional Search Field
              if (widget.showSearch && widget.options.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GlobalTextField(
                    fieldName: 'Search...',
                    keyBoardType: TextInputType.text,
                    textController: _searchController,
                    isOptional: true,
                    removeSpace: false,
                    maxLength: 100,
                    borderRadius: 12,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),

              // Options
              Flexible(
                child: _filteredOptions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                color: AppColors.muted,
                                size: 32,
                              ),
                              addVerticalSpacing(1.18),
                              AppText(
                                text: widget.options.isEmpty
                                    ? widget.emptyMessage
                                    : 'No matching results.',
                                type: AppTextType.bodySmall,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _filteredOptions.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final item = _filteredOptions[index];
                          return Material(
                            color: AppColors.surface,
                            child: ListTile(
                              title: AppText(
                                text: item,
                                type: AppTextType.bodySmall,
                                fontSize: 12.textSize,
                                color: AppColors.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Source Sans 3',
                              ),
                              onTap: () => Navigator.pop(context, item),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomMultipleDropdownBottomSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final bool showSearch;

  /// Values that should already be selected when opening
  final List<String> initialSelected;

  const CustomMultipleDropdownBottomSheet({
    super.key,
    required this.title,
    required this.options,
    this.showSearch = false,
    this.initialSelected = const [],
  });

  @override
  State<CustomMultipleDropdownBottomSheet> createState() =>
      _CustomMultipleDropdownBottomSheetState();
}

class _CustomMultipleDropdownBottomSheetState
    extends State<CustomMultipleDropdownBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _filteredOptions;

  /// Stores user selections
  late Set<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _selectedItems = widget.initialSelected
        .toSet(); // 👈 start with pre-selected

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredOptions = widget.options
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmSelection() {
    Navigator.pop(context, _selectedItems.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: Container(
        height: 80.heightAdjusted,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Title + Close Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      text: widget.title,
                      type: AppTextType.bodyMedium,
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppButton(
                    text: "Done",
                    onPressed: _confirmSelection,
                    widthPercent: 20,
                    heightPercent: 4,
                    btnColor: AppColors.primary,
                    isLoading: false,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.muted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Optional Search
            if (widget.showSearch)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: GlobalTextField(
                  fieldName: 'Search...',
                  keyBoardType: TextInputType.text,
                  textController: _searchController,
                  isOptional: true,
                  removeSpace: false,
                  maxLength: 100,
                  borderRadius: 12,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),

            // List with checkboxes
            Expanded(
              child: ListView.separated(
                itemCount: _filteredOptions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final item = _filteredOptions[index];
                  final isSelected = _selectedItems.contains(item);

                  return Material(
                    color: AppColors.surface,
                    child: CheckboxListTile(
                      value: isSelected,
                      title: AppText(
                        text: item,
                        type: AppTextType.bodyMedium,
                        textAlign: TextAlign.start,

                        color: AppColors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedItems.add(item);
                          } else {
                            _selectedItems.remove(item);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
