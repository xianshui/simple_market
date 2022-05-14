import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/api.dart';
import '../constants.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({Key? key}) : super(key: key);

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> with TickerProviderStateMixin {
  List<String> titles = ['All', 'Spot', 'Futures'];
  List<MarketRecord> marketRecords = [];
  //String keyword = '';
  TextEditingController keywordController = TextEditingController();

  late TabController tabController =
      TabController(vsync: this, length: titles.length, initialIndex: 0);

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() async {
    marketRecords = await Api.getMarketRecords();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: AppBar(
            brightness: Brightness.light,
            iconTheme: IconThemeData(color: Colors.black),
            elevation: 1,
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Text(
              'Market',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ),
        ),
        body: Container(
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    buildTabBar(),
                    buildSearchBar(),
                    Expanded(child: buildTable(tabController.index))
                  ],
                )),
          ),
        ));
  }

  Widget buildTabBar() {
    return TabBar(
        labelPadding: EdgeInsets.symmetric(
          vertical: 10,
        ),
        indicatorWeight: 4,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: AppColors.main,
        controller: tabController,
        tabs: List.generate(
            titles.length,
            (i) => Text(
                  titles[i],
                  style: TextStyle(
                    color: tabController.index == titles.indexOf(titles[i])
                        ? Colors.black
                        : Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                )),
        onTap: (index) {
          setState(() {
            keywordController.text = '';
          });
        });
  }

  Widget buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: keywordController,
        style: TextStyle(fontSize: 14),
        keyboardAppearance: Brightness.light,
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: AppColors.main,
          )),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: AppColors.grey,
          )),
          filled: true,
          hintText: 'Search record',
          hintStyle: TextStyle(color: Color(0x80707070)),
          fillColor: Colors.transparent,
        ),
        onChanged: (str) {
          setState(() {
            //keyword = str;
          });
        },
      ),
    );
  }

  Widget buildTable(int tabIndex) {
    final filteredRecords = marketRecords.where((e) {
      if (tabIndex == 1) {
        return e.type == 'SPOT';
      } else if (tabIndex == 2) {
        return e.type == 'FUTURES';
      }

      return true;
    }).toList();

    final keyword = keywordController.text.trim();
    final searchedRecords = keyword.isEmpty
        ? filteredRecords
        : filteredRecords.where((e) {
            return e.base.contains(keyword);
          }).toList();

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Symbol',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Last Price', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Volume', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            color: Colors.grey,
          ),
          Expanded(
              child: searchedRecords.isEmpty
                  ? Center(
                      child: Text('No results found'),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        return MarketRecordItem(
                            marketRecord: searchedRecords[index]);
                      },
                      itemCount: searchedRecords.length,
                    )),
        ],
      ),
    );
  }
}

class MarketRecordItem extends StatelessWidget {
  final MarketRecord marketRecord;

  const MarketRecordItem({Key? key, required this.marketRecord})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 20;
    final symbol = marketRecord.type == 'SPOT'
        ? '${marketRecord.base}/${marketRecord.quote}'
        : '${marketRecord.base}-PERP';
    final numberFormat = NumberFormat("#,##0.00", "en_US");
    final numberCompact = NumberFormat.compact(locale: "en_US");

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 3 / 10,
            child: Text(symbol),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: width * 3 / 10,
            child: Text('\$${numberFormat.format(marketRecord.lastPrice)}'),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: width * 2 / 5,
            child: Text('\$${numberCompact.format(marketRecord.volume)}'),
          ),
        ],
      ),
    );
  }
}
