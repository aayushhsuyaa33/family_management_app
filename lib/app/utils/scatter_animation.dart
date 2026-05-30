// import 'dart:math';
// import 'package:flutter/material.dart';

// class DeletableTile extends StatefulWidget {
//   final Widget child;
//   final bool isDeleting;
//   final Duration duration;

//   const DeletableTile({
//     super.key,
//     required this.child,
//     required this.isDeleting,
//     this.duration = const Duration(milliseconds: 500),
//   });

//   @override
//   State<DeletableTile> createState() => _DeletableTileState();
// }

// class _DeletableTileState extends State<DeletableTile>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _opacity;


//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(vsync: this, duration: widget.duration);

//     _opacity = Tween<double>(begin: 1, end: 0).animate(_controller);

    
   

//     if (widget.isDeleting) {
//       _controller.forward();
//     }
//   }

//   @override
//   void didUpdateWidget(covariant DeletableTile oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (widget.isDeleting && !oldWidget.isDeleting) {
//       _controller.forward();
//     }
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return AnimatedOpacity(

      
//   //     child:widget.child);
//   //   );
//   // }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
