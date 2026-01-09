import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthListTile extends StatefulWidget {
  const AuthListTile(
      {super.key,
      this.controller,
      this.leadingIcon,
      this.title,
      this.subtitle,
      this.maxChar,
      this.deny,
      this.obscureText});

  final TextEditingController? controller;
  final IconData? leadingIcon;
  final String? title;
  final String? subtitle;
  final int? maxChar;
  final RegExp? deny;
  final bool? obscureText;

  @override
  State<AuthListTile> createState() => _AuthListTileState();
}

class _AuthListTileState extends State<AuthListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 0,
      horizontalTitleGap: 5,
      minTileHeight: 0,
      dense: true,
      contentPadding: const EdgeInsets.all(10),
      leading: Icon(widget.leadingIcon, size: 20),
      title: Text(widget.title!,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: TextField(
        controller: widget.controller,
        inputFormatters: [
          LengthLimitingTextInputFormatter(widget.maxChar ?? 50),
          FilteringTextInputFormatter.deny(widget.deny ?? RegExp(r"\s")),
        ],
        style: const TextStyle(fontSize: 12, height: 1.5),
        obscureText: widget.obscureText ?? false,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: widget.subtitle,
          hintStyle: const TextStyle(fontSize: 12, height: 1),
        ),
      ),
    );
  }
}
