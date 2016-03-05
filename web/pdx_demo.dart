import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'dart:svg';
import 'package:poisson_disc_x/poisson_disc_x.dart';

void main() {

  int bloat = 16;
  double cellWidth = 8.0;

  SvgSvgElement svg = new SvgSvgElement()
    ..setAttribute('viewBox', '0 0 ${bloat*cellWidth} ${bloat*cellWidth}');
  querySelector('#display').append(svg);

  PoissonDiscX pdx = new PoissonDiscX(bloat, cellWidth * SQRT2);

  Timer timer = new Timer.periodic(new Duration(milliseconds:250), (t) {
    if(!pdx.step()) {
      drawFinal(svg, pdx);
      t.cancel();
    } else {
      draw(svg, pdx);
    }
  });
}


draw(SvgSvgElement svg, PoissonDiscX pdx) {
  svg.children.clear();
  for(GridCell parent in pdx.grid) {
    if(parent.sample != null) {
      drawGridCell(svg, parent);
    } else {
      for(Cell cell in parent.cells) {
        drawCell(svg, cell);
      }
    }
  }
}

drawCell(SvgSvgElement svg, Cell cell) {

  RectElement rect = new RectElement()
    ..setAttribute('x', '${cell.center.x-(cell.parent.parent.cellWidth/2)}')
    ..setAttribute('y', '${cell.center.y-(cell.parent.parent.cellWidth/2)}')
    ..setAttribute('width',  '${cell.parent.parent.cellWidth}')
    ..setAttribute('height', '${cell.parent.parent.cellWidth}')
    ..classes.add('cell');

  if(cell.parent.parent.clearCells.contains(cell)) {
    rect.classes.add('clear');
  }

  svg.append(rect);
}

drawGridCell(SvgSvgElement svg, GridCell gridCell) {
  svg.append(new CircleElement()
    ..setAttribute('cx', '${gridCell.sample.x}')
    ..setAttribute('cy', '${gridCell.sample.y}')
    ..setAttribute('r',  '${gridCell.parent.discRadius}')
    ..classes.add('outer'));
  svg.append(new CircleElement()
    ..setAttribute('cx', '${gridCell.sample.x}')
    ..setAttribute('cy', '${gridCell.sample.y}')
    ..setAttribute('r',  '${gridCell.parent.discRadius/2}')
    ..classes.add('inner'));
  svg.append(new CircleElement()
    ..setAttribute('cx', '${gridCell.sample.x}')
    ..setAttribute('cy', '${gridCell.sample.y}')
    ..setAttribute('r',  '${gridCell.parent.discRadius/16}')
    ..classes.add('sample'));
}

drawFinal(SvgSvgElement svg, PoissonDiscX pdx) {
  svg.children.clear();
  for(GridCell parent in pdx.grid) {
    if(parent.sample != null) {
      svg.append(new CircleElement()
        ..setAttribute('cx', '${parent.sample.x}')
        ..setAttribute('cy', '${parent.sample.y}')
        ..setAttribute('r',  '${parent.parent.discRadius/2}')
        ..classes.add('inner'));
      svg.append(new CircleElement()
        ..setAttribute('cx', '${parent.sample.x}')
        ..setAttribute('cy', '${parent.sample.y}')
        ..setAttribute('r',  '${parent.parent.discRadius/16}')
        ..classes.add('sample'));
    }
  }
}