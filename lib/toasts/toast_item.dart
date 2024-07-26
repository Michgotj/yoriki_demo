import 'package:flutter/material.dart';

import 'toast_model.dart';

class ToastItem extends StatelessWidget {
  const ToastItem({
    Key? key,
    this.onTap,
    required this.animation,
    required this.item,
  }) : super(key: key);

  final Animation<double> animation;
  final VoidCallback? onTap;
  final MyToastModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          child: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                color: _getTypeColor(item.type),
                child: Text(item.message,
                    style: const TextStyle(color: Colors.white, fontSize: 22)),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: InkWell(
                      child: const Icon(
                        Icons.close,
                        size: 28,
                        color: Colors.white,
                      ),
                      onTap: () => onTap?.call()),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF006838);
      case ToastType.warning:
        return const Color(0xFFFFD873);
      case ToastType.info:
        return const Color(0xFF17A2b8);
      case ToastType.failed:
        return const Color(0xFFBE141B);
      default:
        return const Color(0xFF3DD89B);
    }
  }

  // String _getTypeString
}
