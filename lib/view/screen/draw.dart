import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreenFill(),
    );
  }
}

class FilterSwitch extends StatefulWidget {
  final String label;
  final Function(bool) onChanged;
  final bool initialValue;

  const FilterSwitch({super.key, 
    required this.label,
    required this.onChanged,
    required this.initialValue,
  });

  @override
  _FilterSwitchState createState() => _FilterSwitchState();
}

class _FilterSwitchState extends State<FilterSwitch> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoFormRow(
      prefix: Text(widget.label),
      child: CupertinoSwitch(
        value: _value,
        onChanged: (newValue) {
          setState(() {
            _value = newValue;
          });
          widget.onChanged(newValue);
        },
      ),
    );
  }
}

class HomeScreenFill extends StatefulWidget {
  const HomeScreenFill({super.key});

  @override
  _HomeScreenFillState createState() => _HomeScreenFillState();
}

class _HomeScreenFillState extends State<HomeScreenFill> {
  List<String> selectedFilters = [];

  void _openFilterDialog() async {
    final selected = await showCupertinoDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        List<String> filters = ['Option 1', 'Option 2', 'Option 3'];

        return CupertinoAlertDialog(
          title: Text('Select Filters'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: filters.map((filter) {
                final isSelected = selectedFilters.contains(filter);

                return FilterSwitch(
                  label: filter,
                  initialValue: isSelected,
                  onChanged: (bool newValue) {
                    setState(() {
                      if (newValue) {
                        selectedFilters.add(filter);
                      } else {
                        selectedFilters.remove(filter);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Apply'),
              onPressed: () {
                Navigator.of(context).pop(selectedFilters);
              },
            ),
          ],
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedFilters = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Selection Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Selected Filters:'),
            Text(selectedFilters.join(', ')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openFilterDialog,
              child: Text('Open Filter Dialog'),
            ),
          ],
        ),
      ),
    );
  }
}
