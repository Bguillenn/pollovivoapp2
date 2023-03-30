import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressRefreshAction extends StatelessWidget {
  final bool isLoading;
  final IconData iconShow;
  final Function() onPressed;

  ProgressRefreshAction(this.isLoading,this.iconShow, this.onPressed );
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      final theme = Theme.of(context);
      final iconTheme =
          theme.appBarTheme.actionsIconTheme ?? theme.primaryIconTheme;
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            width: iconTheme.size ?? 24,
            height: iconTheme.size ?? 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(iconTheme.color),
            ),
          ),
        ),
      ]);
    }
    return IconButton(
      icon: Icon(iconShow),
      onPressed: onPressed,
    );
  }
}