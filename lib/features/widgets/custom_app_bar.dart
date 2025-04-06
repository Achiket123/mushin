import 'package:flutter/material.dart';

AppBar CustomAppBar(double height, double width) {
  return AppBar(
    toolbarHeight: height * 0.1,
    title: Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(248, 248, 248, 1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(115, 69, 69, 69),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      width: width * 0.9,
      height: 53,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(flex: 5, child: Center(child: const Text('Mushin'))),
        ],
      ),
    ),
    centerTitle: true,
    backgroundColor: Color.fromRGBO(123, 123, 123, 1),
  );
}
