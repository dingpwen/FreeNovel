import 'package:flutter/material.dart';

class BaseTabBarWidget extends StatefulWidget{
  BaseTabBarWidget({this.title, this.backgroundColor, this.indicatorColor, this.pageController, this.tabItems, this.tabViews});
  final Widget title;
  final Color backgroundColor;
  final Color indicatorColor;
  final PageController pageController;
  final List<Widget> tabItems;
  final List<Widget> tabViews;

  @override
  State<StatefulWidget> createState() {
    return BaseTabBarState(backgroundColor, indicatorColor, pageController, tabItems, tabViews);
  }
}

class BaseTabBarState extends State<BaseTabBarWidget> with SingleTickerProviderStateMixin{
  BaseTabBarState(this._backgroundColor, this._indicatorColor, this._pageController, this._tabItems, this._tabViews);
  final Color _backgroundColor;
  final Color _indicatorColor;
  final PageController _pageController;
  final List<Widget> _tabItems;
  final List<Widget> _tabViews;
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: _tabItems.length);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _tabViews,
        onPageChanged: (index){
          _tabController.animateTo(index);
        },
      ),
      bottomNavigationBar: new Material(
        color: _backgroundColor,
        child: TabBar(
          controller: _tabController,
          tabs: _tabItems,
          indicatorColor: _indicatorColor,
        ),
      ),
    );
  }
  
}