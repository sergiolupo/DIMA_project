import 'package:flutter/cupertino.dart';

class CustomBinaryOption extends StatefulWidget {
  final String textLeft;
  final String textRight;

  const CustomBinaryOption({
    required this.textLeft,
    required this.textRight,
    super.key,
  });

  @override
  CustomBinaryOptionState createState() => CustomBinaryOptionState();
}

class CustomBinaryOptionState extends State<CustomBinaryOption> {
  bool lr = false;

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
                      lr = false;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.textLeft,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: lr == false
                              ? CupertinoTheme.of(context).primaryColor
                              : CupertinoColors.inactiveGray,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: lr == false ? 3 : 1,
                        color: lr == false
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
                      lr = true;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.textRight,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: lr == true
                              ? CupertinoTheme.of(context).primaryColor
                              : CupertinoColors.inactiveGray,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: lr == true ? 3 : 1,
                        color: lr == true
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
