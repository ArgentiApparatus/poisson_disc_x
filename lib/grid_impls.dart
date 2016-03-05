library grid_impls;

import 'dart:math';
import 'dart:collection';
import 'package:vector_math/vector_math.dart';


// Poisson Disc grid implementations for relative speed testing


abstract class Grid {

  final double _cellSize;
  final double _radiusSq;
  final int _wdth, _hght;
  Grid(Vector2 range, double radius, int padding):
    _cellSize = radius / SQRT2,
    _radiusSq = radius * radius,
    _wdth = ((SQRT2 * range.x) / radius).ceil() + (2 * padding),
    _hght = ((SQRT2 * range.y) / radius).ceil() + (2 * padding);

  /// Remove all samples;
  void clear();

  /// Add [sample] without testing
  void add(Vector2 sample);

  /// Test [cand], if good and return true, otherwise return false.
  bool test(Vector2 cand);
}


/// Cells in 2D array
class ArrayGrid extends Grid {

  List<List<Vector2>> _storage;

  ArrayGrid(Vector2 range, double radius): super(range, radius, 4) {
    _storage = new List<List<Vector2>>.generate(_wdth, (_) => new List<Vector2>.generate(_hght, (_) => null));
  }

  void clear() {
    for(List l in _storage) {
      l.fillRange(0, l.length, null);
    }
  }

  void add(Vector2 sample) {
    _storage[(sample.x / _cellSize).floor() + 2][(sample.y/_cellSize).floor() + 2] = sample;
  }

  bool test(Vector2 cand) {

    // Find sample 'home cell'
    int r = (cand.x / _cellSize).floor() + 2;
    int s = (cand.y / _cellSize).floor() + 2;

    // Test home cell
    if(_storage[r][s] != null) return false;

    // Test surrounding cells in decreasing probabilty order (based on max possible overlap of sample and cell)
    Vector2 p;
    p = _storage[r+1][s];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r-1][s];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r][s+1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r][s-1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r+1][s+1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r+1][s-1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r-1][s+1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r-1][s-1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;

    p = _storage[r+2][s];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r-2][s];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r][s+2];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r][s-2];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r+1][s+2];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r+2][s+1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r+1][s-2];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r+2][s-1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r-1][s+2];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r-2][s+1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r-1][s-2];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[r-2][s-1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;

    _storage[r][s] = cand;

    return true;
  }
}


/// Cells stored in 1D array, Neighbors found be precomputed offsets from cell position in array
class ShiftGrid extends Grid {

  List<Vector2> _storage;

  ShiftGrid(Vector2 range, double radius): super(range, radius, 2) {
    _storage = new List<Vector2>.generate(_wdth * _hght, (_) => null);
  }

  void clear() { _storage.fillRange(0, _storage.length, null); }

  void add(Vector2 sample) { _storage[(sample.x ~/ _cellSize) + 2 + (((sample.y ~/ _cellSize) + 2) * _wdth)] = sample; }

  bool test(Vector2 cand) {

    int index = (cand.x ~/ _cellSize) + 2 + (((cand.y ~/ _cellSize) + 2) * _wdth);
    if(_storage[index] != null) return false;

    // Test surrounding cells in decreasing probabilty order (based on max possible overlap of sample and cell)
    Vector2 p;
    p = _storage[index+1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-_wdth];

    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+1+_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+1-_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-1+_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-1-_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;

    p = _storage[index+2];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-2];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;

    p = _storage[index+2+_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+2-_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-2+_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-2-_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;

    p = _storage[index+1+(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+1-(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-1+(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-1-(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;

    _storage[index] = cand;

    return true;
  }
}

class _LinkedGridCell {
  Vector2 sample;
  Iterable<_LinkedGridCell> neighbors = new List<_LinkedGridCell>();
}


/// Cells stored in 1D array, each cell has links to its neighbors in testing order
class LinkedGrid extends Grid {

  List<_LinkedGridCell> _storage;

  LinkedGrid(Vector2 range, double radius): super(range, radius, 2) {
    _storage  = new List<_LinkedGridCell>.generate(_wdth * _hght, (_) => new _LinkedGridCell());

    // Monster set up

    List<_LinkedGridCell> neighbors;
    int cl = 0;              // Clearance to left
    int cr = _wdth-1;  // Clearance to right
    int cb = 0;              // Clearance to bottom
    int ct = _hght-1;  // Clearance to top
    int index = 0;

    for(_LinkedGridCell cell in _storage) {

      neighbors = cell.neighbors;

      // Vertical and horizontal inner neighbors
      if(cr>0) neighbors.add(_storage[index+1]);
      if(cl>0) neighbors.add(_storage[index-1]);
      if(ct>0) neighbors.add(_storage[index+_wdth]);
      if(cb>0) neighbors.add(_storage[index-_wdth]);

      // Diagonal inner neighbors
      if(cr>0 && ct>0) neighbors.add(_storage[index+1+_wdth]);
      if(cr>0 && cb>0) neighbors.add(_storage[index+1-_wdth]);
      if(cl>0 && ct>0) neighbors.add(_storage[index-1+_wdth]);
      if(cl>0 && cb>0) neighbors.add(_storage[index-1-_wdth]);

      // Vertical and horizontal outer neighbors
      if(cr>1) neighbors.add(_storage[index+2]);
      if(cl>1) neighbors.add(_storage[index-2]);
      if(ct>1) neighbors.add(_storage[index+2*_wdth]);
      if(cb>1) neighbors.add(_storage[index-2*_wdth]);

      // Diagonal outer neighbors
      if(cr>1 && ct>0) neighbors.add(_storage[index+2+_wdth]);
      if(cr>1 && cb>0) neighbors.add(_storage[index+2-_wdth]);
      if(cl>1 && ct>0) neighbors.add(_storage[index-2+_wdth]);
      if(cl>1 && cb>0) neighbors.add(_storage[index-2-_wdth]);
      if(cr>0 && ct>1) neighbors.add(_storage[index+1+(2*_wdth)]);
      if(cr>0 && cb>1) neighbors.add(_storage[index+1-(2*_wdth)]);
      if(cl>0 && ct>1) neighbors.add(_storage[index-1+(2*_wdth)]);
      if(cl>0 && cb>1) neighbors.add(_storage[index-1-(2*_wdth)]);

      index++;
      if(cr > 0) { cl++; cr--; } else { cr=cl; cl=0; cb++; ct--; }
    }
  }

  void clear() { for(_LinkedGridCell c in _storage) { c.sample = null; } }

  void add(Vector2 sample) { _index(sample).sample = sample; }

  bool test(Vector2 cand) {
    _LinkedGridCell cell = _index(cand);
    if(cell.sample != null) return false;
    for(_LinkedGridCell n in cell.neighbors) {
      if(n.sample != null && cand.distanceToSquared(n.sample) < _radiusSq) return false;
    }
    cell.sample = cand;
    return true;
  }

  /// Return cell corresponding to [sample]
  _LinkedGridCell _index(Vector2 sample) {
    return _storage[(sample.x ~/ _cellSize) + ((sample.y ~/ _cellSize)) * _wdth];
  }
}




/// Cells stored in 1D array, each cell has links to its neighbors in testing order
class LinkedArrayGrid extends Grid {

  List<List<_LinkedGridCell>> _storage;

  LinkedArrayGrid(Vector2 range, double radius): super(range, radius, 2) {
    _storage = new List<List<_LinkedGridCell>>.generate(_wdth, (_) => new List<_LinkedGridCell>.generate(_hght, (_) => new _LinkedGridCell(), growable:false), growable:false);

    // Monster set up

    for(int x=0; x<_storage.length; x++) {
      List<_LinkedGridCell> col = _storage[x];
      for(int y=0; y<col.length; y++) {
        List<_LinkedGridCell> neighbors = col[y].neighbors;

        col[x].sample = new Vector2(x.toDouble(), y.toDouble());

        int cl = x;
        int cb = y;
        int cr = _wdth - (x + 1);
        int ct = _hght - (y + 1);

        // Vertical and horizontal inner neighbors
        if(cr>0) neighbors.add(_storage[x+1][y]);
        if(cl>0) neighbors.add(_storage[x-1][y]);
        if(ct>0) neighbors.add(_storage[x][y+1]);
        if(cb>0) neighbors.add(_storage[x][y-1]);

        // Diagonal inner neighbors
        if(cr>0 && ct>0) neighbors.add(_storage[x+1][y+1]);
        if(cr>0 && cb>0) neighbors.add(_storage[x+1][y-1]);
        if(cl>0 && ct>0) neighbors.add(_storage[x-1][y+1]);
        if(cl>0 && cb>0) neighbors.add(_storage[x-1][y-1]);

        // Vertical and horizontal outer neighbors
        if(cr>1) neighbors.add(_storage[x+2][y]);
        if(cl>1) neighbors.add(_storage[x-2][y]);
        if(ct>1) neighbors.add(_storage[x][y+2]);
        if(cb>1) neighbors.add(_storage[x][y-2]);

        // Diagonal outer neighbors
        if(cr>1 && ct>0) neighbors.add(_storage[x+2][y+1]);
        if(cr>1 && cb>0) neighbors.add(_storage[x+2][y-1]);
        if(cl>1 && ct>0) neighbors.add(_storage[x-2][y+1]);
        if(cl>1 && cb>0) neighbors.add(_storage[x-2][y-1]);
        if(cr>0 && ct>1) neighbors.add(_storage[x+1][y+2]);
        if(cr>0 && cb>1) neighbors.add(_storage[x+1][y-2]);
        if(cl>0 && ct>1) neighbors.add(_storage[x-1][y+2]);
        if(cl>0 && cb>1) neighbors.add(_storage[x-1][y-2]);

      }
    }
  }

  void clear() {
    for(List l in _storage) {
      for(_LinkedGridCell c in l) {
        c.sample = null;
      }
    }
  }

  void add(Vector2 sample) {
    _cell(sample).sample = sample;
  }

  bool test(Vector2 cand) {
    _LinkedGridCell cell = _cell(cand);
    if(cell.sample != null) return false;
    for(_LinkedGridCell n in cell.neighbors) {
      if(n.sample != null && cand.distanceToSquared(n.sample) < _radiusSq) return false;
    }
    cell.sample = cand;
    return true;
  }

  _LinkedGridCell _cell(Vector2 point) {
    return _storage[(point.x~/_cellSize) + 2][(point.y~/_cellSize) + 2];
  }
}


/// Cells in SplayTreeMap
class MapGrid extends Grid {

  Map<int, Vector2> _storage  = new SplayTreeMap<int, Vector2>();

  MapGrid(Vector2 range, double radius): super(range, radius, 4);

  void clear() {
    _storage.clear();
  }

  void add(Vector2 sample) {
    _storage[(sample.x ~/ _cellSize) + 2 + (((sample.y ~/ _cellSize) + 2) * _wdth)] = sample;
  }

  bool test(Vector2 cand) {

    int index = (cand.x ~/ _cellSize) + 2 + (((cand.y ~/ _cellSize) + 2) * _wdth);
    if(_storage[index] != null) return false;

    Vector2 p;
    p = _storage[index+1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-1];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-_wdth];

    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+1+_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+1-_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-1+_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-1-_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;

    p = _storage[index+2];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-2];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;

    p = _storage[index+2+_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+2-_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-2+_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-2-_wdth];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;

    p = _storage[index+1+(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index+1-(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-1+(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;
    p = _storage[index-1-(2*_wdth)];
    if(p!=null && p.distanceToSquared(cand) < _radiusSq) return false;

    _storage[index] = cand;

    return true;
  }
}

/// Cells in 2D array, different implementation of test()
class ArrayGrid1 extends Grid {

List<List<Vector2>> _storage;

ArrayGrid1(Vector2 range, double radius): super(range, radius, 4) {
  _storage = new List<List<Vector2>>.generate(_wdth, (_) => new List<Vector2>.generate(_hght, (_) => null));
}

void clear() {
  for(List l in _storage) {
    l.fillRange(0, l.length, null);
  }
}

void add(Vector2 sample) {
  _storage[(sample.x / _cellSize).floor() + 2][(sample.y/_cellSize).floor() + 2] = sample;
}

bool test(Vector2 cand) {

  // Find sample 'home cell'
  int r = (cand.x / _cellSize).floor() + 2;
  int s = (cand.y / _cellSize).floor() + 2;

  // Test home cell
  if(_storage[r][s] != null) return false;

    // Test surrounding cells in decreasing probabilty order (based on max possible overlap of sample and cell)
    if(_storage[r+1][s]!=null && _storage[r+1][s].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r-1][s]!=null && _storage[r-1][s].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r][s+1]!=null && _storage[r][s+1].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r][s-1]!=null && _storage[r][s-1].distanceToSquared(cand) < _radiusSq) return false;

    if(_storage[r+1][s+1]!=null && _storage[r+1][s+1].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r+1][s-1]!=null && _storage[r+1][s-1].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r-1][s+1]!=null && _storage[r-1][s+1].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r-1][s-1]!=null && _storage[r-1][s-1].distanceToSquared(cand) < _radiusSq) return false;

    if(_storage[r+2][s]!=null && _storage[r+2][s].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r-2][s]!=null && _storage[r-2][s].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r][s+2]!=null && _storage[r][s+2].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r][s-2]!=null && _storage[r][s-2].distanceToSquared(cand) < _radiusSq) return false;

    if(_storage[r+1][s+2]!=null && _storage[r+1][s+2].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r+1][s-2]!=null && _storage[r+1][s-2].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r-1][s+2]!=null && _storage[r-1][s+2].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r-1][s-2]!=null && _storage[r-1][s-2].distanceToSquared(cand) < _radiusSq) return false;

    if(_storage[r+2][s+1]!=null && _storage[r+2][s+1].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r+2][s-1]!=null && _storage[r+2][s-1].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r-2][s+1]!=null && _storage[r-2][s+1].distanceToSquared(cand) < _radiusSq) return false;
    if(_storage[r-2][s-1]!=null && _storage[r-2][s-1].distanceToSquared(cand) < _radiusSq) return false;

    _storage[r][s] = cand;

    return true;
  }
}
