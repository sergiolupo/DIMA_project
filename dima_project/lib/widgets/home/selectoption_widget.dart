import 'package:flutter/cupertino.dart';

class CustomSelectOption extends StatefulWidget {
  final String textLeft;
  final String? textMiddle;
  final String textRight;
  final void Function(int idx) onChanged;

  const CustomSelectOption({
    required this.textLeft,
    required this.textRight,
    this.textMiddle,
    required this.onChanged,
    super.key,
  });

  @override
  CustomSelectOptionState createState() => CustomSelectOptionState();
}

class CustomSelectOptionState extends State<CustomSelectOption> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
        ),
        child: Container(
          color: CupertinoColors.white,
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      idx = 0;
                      widget.onChanged(idx);
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.textLeft,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: idx == 0
                              ? CupertinoTheme.of(context).primaryColor
                              : CupertinoColors.inactiveGray,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: idx == 0 ? 3 : 1,
                        color: idx == 0
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.opaqueSeparator,
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.textMiddle != null)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        idx = 1;
                        widget.onChanged(idx);
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.textMiddle!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: idx == 1
                                ? CupertinoTheme.of(context).primaryColor
                                : CupertinoColors.inactiveGray,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: idx == 1 ? 3 : 1,
                          color: idx == 1
                              ? CupertinoTheme.of(context).primaryColor
                              : CupertinoColors.opaqueSeparator,
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      idx = widget.textMiddle != null ? 2 : 1;
                      widget.onChanged(idx);
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.textRight,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: idx == (widget.textMiddle != null ? 2 : 1)
                              ? CupertinoTheme.of(context).primaryColor
                              : CupertinoColors.inactiveGray,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height:
                            idx == (widget.textMiddle != null ? 2 : 1) ? 3 : 1,
                        color: idx == (widget.textMiddle != null ? 2 : 1)
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.opaqueSeparator,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
