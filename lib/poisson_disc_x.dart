library poisson_disc_x;

import 'dart:math';
import 'package:vector_math/vector_math.dart';

Random _random = new Random();

class PoissonDiscX {

  final double discRadius;

  double cellWidth;  // Current  width of cells
  double cellRadius; // Current radius of cells

  double innerSquared; // Current notFullyAny radius
  double outerSquared; // Current fullyUnAll radius

  List<GridCell> grid;
  List<Cell> clearCells = new List<Cell>();

  PoissonDiscX(int gridWidth, double radius):discRadius = radius {

    cellRadius   = radius / 2;
    cellWidth    = radius / SQRT2;
    innerSquared = pow(discRadius - cellRadius, 2);
    outerSquared = pow(discRadius + cellRadius, 2);

    build(gridWidth);
  }

  void build(int gridWidth) {

    int girth = gridWidth*gridWidth;
    double hw = cellWidth/2;
    int x, y;
    Cell cell;
    GridCell gridCell;

    // Create grid cells
    grid = new List<GridCell>.generate(girth, (int index) {
      x = index % gridWidth;
      y = index ~/ gridWidth;
      return new GridCell(this, new Vector2((x*cellWidth)+hw, (y*cellWidth)+hw));
    });

    // Assign grid cell's neighbors in proper order
    int r, t;
    List<GridCell> neighbors;
    int index = 0;
    for(GridCell gridCell in grid) {

      x = index % gridWidth;
      y = index ~/ gridWidth;
      r = gridWidth-(x+1);
      t = gridWidth-(y+1);
      neighbors = new List();

      // Vertical and horizontal inner neighbors
      if(r>0) neighbors.add(grid[index+1]);
      if(x>0) neighbors.add(grid[index-1]);
      if(t>0) neighbors.add(grid[index+gridWidth]);
      if(y>0) neighbors.add(grid[index-gridWidth]);

      // Diagonal inner neighbors
      if(r>0 && t>0) neighbors.add(grid[index+1+gridWidth]);
      if(r>0 && y>0) neighbors.add(grid[index+1-gridWidth]);
      if(x>0 && t>0) neighbors.add(grid[index-1+gridWidth]);
      if(x>0 && y>0) neighbors.add(grid[index-1-gridWidth]);

      // Vertical and horizontal outer neighbors
      if(r>1) neighbors.add(grid[index+2]);
      if(x>1) neighbors.add(grid[index-2]);
      if(t>1) neighbors.add(grid[index+2*gridWidth]);
      if(y>1) neighbors.add(grid[index-2*gridWidth]);

      // Diagonal outer neighbors
      if(r>1 && t>0) neighbors.add(grid[index+2+gridWidth]);
      if(r>1 && y>0) neighbors.add(grid[index+2-gridWidth]);
      if(x>1 && t>0) neighbors.add(grid[index-2+gridWidth]);
      if(x>1 && y>0) neighbors.add(grid[index-2-gridWidth]);
      if(r>0 && t>1) neighbors.add(grid[index+1+(2*gridWidth)]);
      if(r>0 && y>1) neighbors.add(grid[index+1-(2*gridWidth)]);
      if(x>0 && t>1) neighbors.add(grid[index-1+(2*gridWidth)]);
      if(x>0 && y>1) neighbors.add(grid[index-1-(2*gridWidth)]);

      gridCell.neighbors = neighbors;
      index++;
    }

    findClearCells();
  }

  bool step() {
    if(!sample()) {
      split();
      findClearCells();
      if(clearCells.length == 0) {
        return false;
      }
    }
    return true;
  }

  void findClearCells() {
    clearCells.clear();
    for(GridCell gridCell in grid) {
      if(gridCell.cells != null) {
        clearCells.addAll(gridCell.cells.where((c)=>c.parent.fullyUnAll(c.center)));
      }
    }
  }

  bool sample() {
    if(clearCells.length > 0) {
      Cell cell = clearCells.elementAt(_random.nextInt(clearCells.length));
      cell.sample();
      findClearCells();
      return true;
    }
    return false;
  }

  void split() {
    cellRadius /= 2;
    cellWidth /= 2;
    innerSquared = pow(discRadius - cellRadius, 2);
    outerSquared = pow(discRadius + cellRadius, 2);
    for(GridCell gridCell in grid) {
      gridCell.split();
    }
  }
}



class GridCell {

  final PoissonDiscX parent;
  List<Cell> cells = new List<Cell>();
  Iterable<GridCell> neighbors;
  Vector2 sample;

  GridCell(this.parent, Vector2 center) {
    cells.add(new Cell(center, this));
  }

  /// Accept [sample] from child cell, perform necessary updates
  void takeSample(Vector2 sample) {
    this.sample = sample;

    // All cells now fully covered by sample disc
    cells.clear();
    cells = null;

    // Update neighbors
    for(GridCell neighbour in neighbors) neighbour.update(this.sample);
  }

  /// Remove cells that are now completely covered by new [sample]
  void update(Vector2 sample) {
    if(cells != null) {
      cells.removeWhere((Cell cell) => fully(cell.center, sample));
    }
  }

  /// Split cells,
  void split() {
    if(cells != null) {
      List<Cell> tmp = new List<Cell>.from(cells);
      cells.clear();

      double hw = parent.cellWidth/2;
      for(Cell cell in tmp) {

        Iterable<Cell> newCells =
          [new Vector2.copy(cell.center)..x+=hw..y+=hw,
           new Vector2.copy(cell.center)..x+=hw..y-=hw,
           new Vector2.copy(cell.center)..x-=hw..y+=hw,
           new Vector2.copy(cell.center)..x-=hw..y-=hw]
            .where((Vector2 c) => notFullyAny(c))
            .map((Vector2 c) => new Cell(c, this));

      cells.addAll(newCells);
      }
    }
  }

  /// Test circle at [center] of current cell radius completely covered by [sample]'s disc
  bool fully(Vector2 center, Vector2 sample) => center.distanceToSquared(sample) < parent.innerSquared;

  /// Test circle at [center] of current cell radius at least partially covered by [sample]'s disc
  bool partially(Vector2 center, Vector2 sample) => center.distanceToSquared(sample) < parent.outerSquared;

  /// Test circle at [center] of current cell radius not completely covered by any sample's disc
  bool notFullyAny(Vector2 center) {
    for(GridCell neighbor in neighbors) {
      if(neighbor.sample!=null && center.distanceToSquared(neighbor.sample) < parent.innerSquared) return false;
    }
    return true;
  }

  /// Test circle at [center] of current cell radius fully uncovered by all samples discs
  bool fullyUnAll(Vector2 center) {
    for(GridCell neighbor in neighbors) {
      if(neighbor.sample!=null && center.distanceToSquared(neighbor.sample) < parent.outerSquared) return false;
    }
    return true;
  }
}


class Cell {

  final Vector2 center;
  final GridCell parent;
  Cell(this.center, this.parent);

  /// Generate random sample in cell area, invoke GridCell actions for new sample
  void sample() {
    double hw = parent.parent.cellWidth/2;
    parent.takeSample(new Vector2.copy(center)
      ..x += ((parent.parent.cellWidth * _random.nextDouble()) - hw)
      ..y += ((parent.parent.cellWidth * _random.nextDouble()) - hw));
  }
}