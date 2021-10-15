import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DateTimePickerType { date, time, dateTime }

class DateTimeFormField extends FormField<String> {
  DateTimeFormField({
    Key key,
    this.type = DateTimePickerType.date,
    this.controller,
    this.decoration,
    this.onChanged,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  }) : super(
            key: key,
            onSaved: onSaved,
            validator: validator,
            builder: (field) {
              final _DateTimeFormFieldState state = field;

              //   void onChangedHandler(String value) {
              //   if (onChanged != null) {
              //     onChanged(value);
              //   }
              //   field.didChange(value);
              // }

              Widget buildField(DateTimePickerType peType) {
                Function lfOnTap;
                switch (peType) {
                  case DateTimePickerType.time:
                    lfOnTap = state._showTimePickerDialog;

                    break;
                  case DateTimePickerType.dateTime:
                    lfOnTap = state._showDateTimePickerDialog;

                    break;
                  default:
                    lfOnTap = state._showDatePickerDialog;
                }

                return TextField(
                  readOnly: true,
                  onTap: lfOnTap,
                  controller: state._dateLabelController,
                  decoration: decoration.copyWith(errorText: field.errorText),
                );
              }

              return buildField(type);
            });

  final DateTimePickerType type;
  final TextEditingController controller;
  final InputDecoration decoration;
  final ValueChanged<String> onChanged;

  @override
  _DateTimeFormFieldState createState() => _DateTimeFormFieldState();
}

class _DateTimeFormFieldState extends FormFieldState<String> {
  TextEditingController _stateController;
  TextEditingController _dateLabelController = TextEditingController();
  DateTime _dDate = DateTime.now();
  TimeOfDay _tTime = TimeOfDay.now();

  @override
  DateTimeFormField get widget => super.widget;

  TextEditingController get _effectiveController =>
      widget.controller ?? _stateController;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _stateController = TextEditingController();
    } else {
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(DateTimeFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _stateController =
            TextEditingController.fromValue(oldWidget.controller.value);
      }

      if (widget.controller != null) {
        setValue(widget.controller.text);

        if (oldWidget.controller == null) {
          _stateController = null;
        }
      }
    }
  }

  void _handleControllerChanged() {
    if (_effectiveController.text != value)
      didChange(_effectiveController.text);
  }

  void onChangedHandler(String value) {
    if (widget.onChanged != null) {
      widget.onChanged(value);
    }

    didChange(value);
  }

  Future<void> _showDatePickerDialog() async {
    DateTime ldDatePicked = await showDatePicker(
      context: context,
      initialDate: _dDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (ldDatePicked != null) {
      _dateLabelController.text =
          DateFormat('MMM dd, yyyy').format(ldDatePicked);
      _effectiveController.text = DateFormat('yyyy-MM-dd').format(ldDatePicked);

      onChangedHandler(_effectiveController.text);
    }
  }

  Future<void> _showTimePickerDialog() async {
    TimeOfDay ltTimePicked = await showTimePicker(
      context: context,
      initialTime: _tTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
    );

    if (ltTimePicked != null) {
      String lsHour = ltTimePicked.hour.toString().padLeft(2, '0');
      String lsMinute = ltTimePicked.minute.toString().padLeft(2, '0');

      _dateLabelController.text = '$lsHour:$lsMinute';
      _effectiveController.text = '$lsHour:$lsMinute';

      onChangedHandler(_effectiveController.text);
    }
  }

  Future<void> _showDateTimePickerDialog() async {
    DateTime ldDatePicked = await showDatePicker(
      context: context,
      initialDate: _dDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (ldDatePicked != null) {
      TimeOfDay ltTimePicked = await showTimePicker(
        context: context,
        initialTime: _tTime ?? TimeOfDay.now(),
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        },
      );

      if (ltTimePicked != null) {
        DateTime combinedDatePicked = combine(ldDatePicked, ltTimePicked);

        _dateLabelController.text =
            DateFormat('h:mm aaa dd MMM yyy').format(combinedDatePicked);
        _effectiveController.text =
            DateFormat('yyyy-MM-dd hh:mm:ss').format(combinedDatePicked);

        onChangedHandler(_effectiveController.text);
      }
    }
  }

  DateTime combine(DateTime date, TimeOfDay time) => DateTime(
      date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);
}
