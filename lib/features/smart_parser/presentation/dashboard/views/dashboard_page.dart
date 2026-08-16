import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/app_colors.dart';
import '../../../../../core/presentation/widgets/custom_bottom_navigation_bar.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../../../../../injection/injection_container.dart' as di;
import 'widgets/dashboard_body.dart';
import '../../../../long_research/presentation/bloc/research_bloc.dart';
import '../../../../long_research/presentation/screens/research_hub_screen.dart';
import '../../../../excel_versioner/excel_versioner_page.dart';
import '../../smart_parser/views/smart_parser_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _navigateToExcelVersioner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ExcelVersionerPage(),
      ),
    );
  }

  void _navigateToResearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.locator<ResearchBloc>(),
          child: const ResearchHubScreen(),
        ),
      ),
    );
  }

  void _navigateToSmartParser() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SmartParserScreen(),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _navigateToExcelVersioner();
      return;
    }
    if (index == 2) {
      _navigateToResearch();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: BlocProvider(
        create: (_) =>
            di.locator<DashboardBloc>()..add(const WatchSavedOrders()),
        child: const SafeArea(child: DashboardBody()),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        onFabPressed: _navigateToSmartParser,
      ),
    );
  }
}
