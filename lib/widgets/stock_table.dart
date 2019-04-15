import 'package:flutter/material.dart';

typedef Function StockTableDelegateOnTap(int rowIndex);

abstract class StockTableDeletgate {
  const StockTableDeletgate();

  int get numColumns;
  int get numRows;
  
  Widget createHeaderCell(BuildContext context, int columnIndex, StockTableView tableView);
  Widget createCell(BuildContext context, int rowIndex, int columnIndex, StockTableView tableView);

  void onTap(BuildContext context, int rowIndex);
}

class DummyStockTableDelegate extends StockTableDeletgate {
  final int numColumns;
  final int numRows;

  const DummyStockTableDelegate({
    this.numColumns = 6,
    this.numRows = 40
  });

  @override
  Widget createCell(
    BuildContext context,
    int rowIndex,
    int columnIndex,
    StockTableView tableView
  ) {
    assert(tableView != null);
    assert(rowIndex >= 0);
    assert(columnIndex >= 0);

    return Container(
      height: tableView.metrics.itemHeight,
      width: tableView.metrics.itemWidth,
      alignment: Alignment.center,
      color: rowIndex.isEven ? Colors.blueGrey[200] : Colors.white,
      child: Text('$rowIndex : $columnIndex'),
    );
  }

  @override
  Widget createHeaderCell(
    BuildContext context,
    int columnIndex,
    StockTableView tableView
  ) {
    assert(tableView != null);
    assert(columnIndex >= 0);
    return Container(
      height: tableView.metrics.itemHeight,
      width: tableView.metrics.itemWidth,
      alignment: Alignment.center,
      color: Colors.green[100 * (columnIndex % 9)],
      child: Text('Column $columnIndex'),
    );
  }

  @override
  void onTap(BuildContext context, int rowIndex) {
    debugPrint("Tap on row $rowIndex");
  }
}

class ItemListStockTableDelegate extends StockTableDeletgate {
  final List<String> _headerNames = List<String>();
  final List<String> _headerKeys = List<String>();
  final List<List<String>> _rows = List<List<String>>();

  ItemListStockTableDelegate({
    List<Map<String, String>> data,
    String primaryKey,
    Map<String, String> headerMap,
  }):
  assert(data != null),
  assert(primaryKey != null),
  assert(headerMap != null)
  {
    _headerNames.add(headerMap[primaryKey]);
    _headerKeys.add(primaryKey);
    headerMap.forEach((k, v) {
      if (k != primaryKey) {
        _headerKeys.add(k);
        _headerNames.add(v);
      }
    });

    data.forEach((item) {
      List<String> itemValues = List<String>(_headerKeys.length);
      item.forEach((k, v) {
        int keyIndex = _headerKeys.indexOf(k);
        if (keyIndex >= 0) {
          itemValues[keyIndex] = v;
        }
      });
      _rows.add(itemValues);
    });
  }

  @override
  Widget createCell(
    BuildContext context,
    int rowIndex,
    int columnIndex,
    StockTableView tableView)
  {
    assert(tableView != null);
    assert(rowIndex >= 0);
    assert(columnIndex >= 0);

    String cellText = "--";
    if (rowIndex >= 0 && rowIndex < _rows.length) {
      List<String> row = _rows[rowIndex];
      if (row != null && columnIndex >= 0 && columnIndex < row.length) {
        cellText = row[columnIndex];
      }
    }

    return Container(
      height: tableView.metrics.itemHeight,
      width: tableView.metrics.itemWidth,
      alignment: Alignment.center,
      color: rowIndex.isEven ? Colors.blueGrey[200] : Colors.white,
      child: Text(cellText),
    );
  }

  @override
  Widget createHeaderCell(
    BuildContext context,
    int columnIndex,
    StockTableView tableView
  ) {
    assert(tableView != null);
    assert(columnIndex >= 0);

    String headerText = "--";
    if (columnIndex >= 0 && columnIndex < _headerNames.length) {
      if (_headerNames[columnIndex] != null) {
        headerText = _headerNames[columnIndex];
      } else if (_headerKeys[columnIndex] != null) {
        headerText = _headerKeys[columnIndex];
      }
    }

    return Container(
      height: tableView.metrics.itemHeight,
      width: tableView.metrics.itemWidth,
      alignment: Alignment.center,
      color: Colors.green[100 * (columnIndex % 9)],
      child: Text(headerText),
    );
  }

  @override
  int get numColumns => _headerNames.length;

  @override
  int get numRows => _rows.length;

  @override
  void onTap(BuildContext context, int rowIndex) {
    // TODO: implement onTap
  }

}

class StockTableMetrics {
  static const double defaultHeaderHeight = 48.0;
  static const double defaultHeaderWidth = 146.0;
  static const double defaultItemHeight = 48.0;
  static const double defaultItemWidth = 146.0;

  final double headerHeight;
  final double primaryHeaderWidth;
  final double headerWidth;
  final double itemHeight;
  final double primaryItemWidth;
  final double itemWidth;

  const StockTableMetrics({
    this.headerHeight = defaultHeaderHeight,
    this.primaryHeaderWidth = defaultHeaderWidth,
    this.headerWidth = defaultHeaderWidth,
    this.itemHeight = defaultItemHeight,
    this.primaryItemWidth = defaultItemWidth,
    this.itemWidth = defaultItemWidth
  });
}

class StockTableView extends StatefulWidget {
  final StockTableDeletgate delegate;
  final StockTableMetrics metrics;

  StockTableView({
    @required this.delegate,
    this.metrics = const StockTableMetrics()
  });

  @override
  State<StatefulWidget> createState() {
    return _StockTableViewState();
  }
}

class _StockTableViewState extends State<StockTableView> {
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _gridScrollController = ScrollController();
  
  List<TableRow> _generateGridRows(BuildContext context) {
    return List<TableRow>.generate(widget.delegate.numRows, (index) {
      return TableRow(
        children: _generateGridCells(context, index),
      );
    });
  }

  List<Widget> _generateGridCells(BuildContext context, int row) {
    return List<Widget>.generate(widget.delegate.numColumns - 1, (index) {
      return widget.delegate.createCell(context, row, index + 1, this.widget);
    });
  }

  List<Widget> _generatePrimaryCells(BuildContext context) {
    return List<Widget>.generate(widget.delegate.numRows, (int index) {
      return widget.delegate.createCell(context, index, 0, this.widget);
    });
  }

  List<Widget> _generateHeaderCells(BuildContext context) {
    return List<Widget>.generate(widget.delegate.numColumns - 1, (index) {
      return widget.delegate.createHeaderCell(context, index + 1, this.widget);
    });
  }

  Widget _makeHeader(BuildContext context) {
    return Row(
      children: <Widget>[
        widget.delegate.createHeaderCell(context, 0, this.widget),
        Expanded(
          child: SingleChildScrollView(
            controller: _headerScrollController,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _generateHeaderCells(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _makeBody(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Row (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: _generatePrimaryCells(context),
            ),

            Expanded(
              child: NotificationListener<ScrollUpdateNotification>(
                child: SingleChildScrollView(
                  controller: _gridScrollController,
                  physics: ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    columnWidths: List<TableColumnWidth>.generate(5, (i) => FixedColumnWidth(146.0)).asMap(),
                    children: _generateGridRows(context),
                  ),
                ),
                onNotification: (notification) {
                  // debugPrint(notification.toString());
                  _headerScrollController.jumpTo(notification.metrics.pixels);
                  return true;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _makeHeader(context),
        _makeBody(context),
      ],
    );
  }
}
