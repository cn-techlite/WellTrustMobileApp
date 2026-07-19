// ignore_for_file: prefer_const_constructors, constant_identifier_names, annotate_overrides, overridden_fields, use_key_in_widget_constructors, must_be_immutable

import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
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
    const borderColor = Color(0xffE2D8C7);
    const hintColor = Color(0xff8E8A82);

    return Container(
      height: 6.heightAdjusted,
      // margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.4),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: hintColor, size: 24),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              onChanged: widget.onChanged,
              cursorColor: AppColors.black,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: hintColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          if (widget.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                widget.onChanged('');
                FocusScope.of(context).unfocus();
              },
              child: const Icon(Icons.close, color: hintColor, size: 24),
            ),
        ],
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
  final Function(String?)? onChanged;
  final Function(String?)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Widget? prefix;
  final Widget? suffix;
  final bool isNotePad;
  final String? confirmPasswordMatch;
  final bool allowDecimal;
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
    this.suffix,
    this.isNotePad = false,
    this.confirmPasswordMatch,
    this.allowDecimal = false, // 👈 default
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
      enabled: true,
      maxLines: widget.isNotePad ? 10 : 1,
      minLines: widget.isNotePad
          ? widget.maxLength <= 100
                ? 3
                : 6
          : 1,
      enableInteractiveSelection: widget.readOnly == true
          ? false
          : true, // prevents long press/double tap menu
      textInputAction: widget.textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      //   textAlign: TextAlign.start,
      textCapitalization: widget.keyBoardType == TextInputType.name
          ? TextCapitalization.sentences
          : TextCapitalization.none,
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
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: widget.fieldName,
        isDense: true,
        // filled: true,
        // fillColor: Color.fromRGBO(239, 239, 239, 1),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
          borderSide: BorderSide(color: AppColors.grey2, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
          borderSide: BorderSide(color: AppColors.grey2, width: 0.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
          borderSide: const BorderSide(color: Colors.red, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
          borderSide: BorderSide(color: AppColors.grey2, width: 0.5),
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

      // fillColor: Color.fromRGBO(239, 239, 239, 1),
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
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
        borderSide: BorderSide(color: AppColors.grey2, width: 0.5),
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
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
          borderSide: BorderSide(color: AppColors.grey2, width: 0.5),
          gapPadding: 40,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
          borderSide: BorderSide(color: AppColors.grey2, width: 0.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
          borderSide: const BorderSide(color: Colors.red, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
          borderSide: BorderSide(color: AppColors.grey2, width: 0.5),
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

class CustomDropdownBottomSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final bool showSearch;

  const CustomDropdownBottomSheet({
    super.key,
    required this.title,
    required this.options,
    this.showSearch = false,
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
          // color: AppColors.white,
          height: 50.heightAdjusted,
          decoration: BoxDecoration(
            color: AppColors.white,
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
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 12.textSize,
                          color: AppColors.black,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Manrope",
                        ),
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
              if (widget.showSearch)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              // Options
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _filteredOptions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final item = _filteredOptions[index];
                    return ListTile(
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 12.textSize,
                          color: AppColors.black,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Manrope",
                        ),
                      ),
                      onTap: () => Navigator.pop(context, item),
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
          color: Colors.white,
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
                    icon: const Icon(Icons.close, color: Colors.grey),
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
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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

                  return CheckboxListTile(
                    value: isSelected,
                    title: AppText(
                      text: item,
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
