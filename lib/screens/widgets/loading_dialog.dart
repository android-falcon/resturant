//packages
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//General loading widget to use anywhere in the app
class LoadingDialog extends StatelessWidget {
  final String title;

  const LoadingDialog({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 200.h,
            maxWidth: 200.w,
          ),
          height: 100.h,
          width: 100.w,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.grey[600],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
