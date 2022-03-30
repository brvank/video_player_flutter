import 'package:flutter/material.dart';

class LinearGraph extends StatefulWidget {
  List<Widget> labels;
  Widget? divider;
  String? title;

  ///keep factor in the range of [0,1]
  double factor;
  LinearGraph({Key? key, required this.labels, required this.factor, this.divider, this.title}) : super(key: key);

  @override
  State<LinearGraph> createState() => _LinearGraphState();
}

class _LinearGraphState extends State<LinearGraph> {

  late List<Widget> dividers;
  late List<Widget> labels;

  @override
  void initState() {
    super.initState();

    if(widget.factor > 1){
      widget.factor = 1;
    }else if(widget.factor < 0){
      widget.factor = 0;
    }

    makeDividers();
    makeLabels();
  }

  void makeDividers(){
    dividers = [];
    for(int i=0;i<widget.labels.length+1;i++){
      dividers.add(widget.divider??Container(
                height: 40,
                width: 4,
                color: Colors.black,
              ));
    }
  }

  void makeLabels(){
    labels = [];
    for(int i=0;i<widget.labels.length;i++){
      labels.add(Expanded(
        flex: 1,
        child: Container(
          alignment: Alignment.center,
          child: widget.labels[i],
        )
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(widget.title??'Linear Graph', style: TextStyle(color: Colors.white, backgroundColor: Colors.black),),
        ),
        LayoutBuilder(
          builder: (context, constraints){
            return Stack(
            alignment: Alignment.center,
            children: [
              Container(height: 4, color: Colors.black,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: dividers,),
              Positioned(
                left: constraints.maxWidth*widget.factor -20/2,
                child: Container(
                  alignment: Alignment.center,
                  child: Icon(
                  Icons.circle,
                  size: 20,
                  color: Colors.red,
              ),
                ),)
            ],
          );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: labels,
        )
      ],
    );
  }
}