import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();

}

class SearchBarWidgetState extends State<SearchBarWidget> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'File Name',
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.search, color: Colors.white),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            _controller.clear();
          },
        )
            : null,
        filled: true,
        fillColor: Colors.grey[800],
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}