import 'package:appflowy_editor/src/editor_state.dart';
import 'package:appflowy_editor/src/infra/flowy_svg.dart';
import 'package:appflowy_editor/src/render/color_menu/color_picker.dart';
import 'package:appflowy_editor/src/render/style/editor_style.dart';
import 'package:flutter/material.dart';

class HighlightColorPicker extends StatefulWidget {
  const HighlightColorPicker({
    super.key,
    this.editorState,
    this.selectedHighlightColorHex,
    required this.pickerBackgroundColor,
    required this.highlightColorOptions,
    required this.pickerItemHoverColor,
    required this.pickerItemTextColor,
    required this.onSubmittedhighlightColorHex,
  });
  final EditorState? editorState;
  final String? selectedHighlightColorHex;
  final Color pickerBackgroundColor;
  final Color pickerItemHoverColor;
  final Color pickerItemTextColor;
  final void Function(String color) onSubmittedhighlightColorHex;

  final List<ColorOption> highlightColorOptions;

  @override
  State<HighlightColorPicker> createState() => _HighlightColorPickerState();
}

class _HighlightColorPickerState extends State<HighlightColorPicker> {
  final TextEditingController _highlightColorHexController =
      TextEditingController();
  final TextEditingController _highlightColorOpacityController =
      TextEditingController();
  EditorStyle? get style => widget.editorState?.editorStyle;

  @override
  void initState() {
    super.initState();
    _highlightColorHexController.text =
        _extractColorHex(widget.selectedHighlightColorHex) ?? 'FFFFFF';
    _highlightColorOpacityController.text =
        _convertHexToOpacity(widget.selectedHighlightColorHex) ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.pickerBackgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
        borderRadius: BorderRadius.circular(6.0),
      ),
      height: 250,
      width: 220,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildHeader('Highlight color'),
              const SizedBox(height: 6),
              _buildCustomColorItem(
                _highlightColorHexController,
                _highlightColorOpacityController,
              ),
              _buildColorItems(
                widget.highlightColorOptions,
                widget.selectedHighlightColorHex,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildColorItems(
    List<ColorOption> options,
    String? selectedColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: options
          .map((e) => _buildColorItem(e, e.colorHex == selectedColor))
          .toList(),
    );
  }

  Widget _buildColorItem(ColorOption option, bool isChecked) {
    return SizedBox(
      height: 36,
      child: TextButton.icon(
        onPressed: () {
          widget.onSubmittedhighlightColorHex(option.colorHex);
        },
        icon: SizedBox.square(
          dimension: 12,
          child: Container(
            decoration: BoxDecoration(
              color: Color(int.tryParse(option.colorHex) ?? 0xFFFFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return style!.popupMenuHoverColor!;
              }
              return Colors.transparent;
            },
          ),
        ),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                option.name,
                style:
                    TextStyle(fontSize: 12, color: widget.pickerItemTextColor),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
            // checkbox
            if (isChecked) const FlowySvg(name: 'checkmark'),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomColorItem(
    TextEditingController colorController,
    TextEditingController opacityController,
  ) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.only(left: 0),
      title: SizedBox(
        height: 36,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 6),
            SizedBox.square(
              dimension: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(
                    int.tryParse(
                          _combineColorHexAndOpacity(
                            colorController.text,
                            opacityController.text,
                          ),
                        ) ??
                        0xFFFFFFFF,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Custom Color',
                style:
                    TextStyle(fontSize: 12, color: widget.pickerItemTextColor),
              ),
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 6),
        _customColorDetailsTextField('Hex Color', colorController),
        const SizedBox(height: 6),
        _customColorDetailsTextField('Opacity', opacityController),
      ],
    );
  }

  Widget _customColorDetailsTextField(
    String labeText,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labeText,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      onSubmitted: (value) {
        final String color = _combineColorHexAndOpacity(
          _highlightColorHexController.text,
          _highlightColorOpacityController.text,
        );
        widget.onSubmittedhighlightColorHex(color);
      },
    );
  }

  String _combineColorHexAndOpacity(String colorHex, String opacity) {
    colorHex = _fixColorHex(colorHex);
    opacity = _fixOpacity(opacity);
    final opacityHex = (int.parse(opacity) * 2.55).round().toRadixString(16);
    return '0x$opacityHex$colorHex';
  }

  String _fixColorHex(String colorHex) {
    if (colorHex.length > 6) {
      colorHex = colorHex.substring(0, 6);
    }
    if (int.tryParse(colorHex, radix: 16) == null) {
      colorHex = 'FFFFFF';
    }
    return colorHex;
  }

  String _fixOpacity(String opacity) {
    RegExp regex = RegExp('[a-zA-Z]');
    if (regex.hasMatch(opacity) ||
        int.parse(opacity) > 100 ||
        int.parse(opacity) < 0) {
      return '100';
    }
    return opacity;
  }

  String? _convertHexToOpacity(String? colorHex) {
    if (colorHex == null) return null;
    final opacityHex = colorHex.substring(2, 4);
    final opacity = int.parse(opacityHex, radix: 16) / 2.55;
    return opacity.toStringAsFixed(0);
  }

  String? _extractColorHex(String? colorHex) {
    if (colorHex == null) return null;
    return colorHex.substring(4);
  }
}
