import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_bootstrap_service.dart';
import '../core/network/cloudinary_service.dart';
import '../core/services/upload_orchestrator.dart';

import '../network_service/network_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../config/flavor_configuration/configuration.dart';
import '../config/flavor_configuration/masar_pro_dev_config.dart';
import '../config/flavor_configuration/masar_pro_prod_config.dart';

// Smart Parser Imports
import '../features/smart_parser/data/datasources/parser_local_data_source.dart';
import '../features/smart_parser/data/datasources/parser_remote_data_source.dart';
import '../features/smart_parser/data/datasources/parser_firestore_datasource.dart';
import '../features/smart_parser/data/repositories/parser_repository_impl.dart';
import '../features/smart_parser/domain/repositories/parser_repository.dart';
import '../features/smart_parser/domain/usecases/analyze_input_usecase.dart';
import '../features/smart_parser/domain/usecases/save_order_usecase.dart';
import '../core/shared/content_generation/domain/usecases/generate_content_usecase.dart';
import '../core/shared/content_generation/data/datasources/content_generation_datasource.dart';
import '../features/smart_parser/domain/usecases/get_saved_orders_usecase.dart';
import '../features/smart_parser/presentation/dashboard/bloc/dashboard_bloc.dart';
import '../features/smart_parser/presentation/order_details/bloc/order_details_bloc.dart';
import '../features/smart_parser/presentation/smart_parser/bloc/smart_parser_bloc.dart';

// Content Creation Imports
import '../features/content_creation/data/datasources/content_creation_remote_data_source.dart';
import '../features/content_creation/data/datasources/content_firestore_datasource.dart';
import '../features/content_creation/data/repositories/content_creation_repository_impl.dart';
import '../features/content_creation/domain/repositories/content_creation_repository.dart';
import '../features/content_creation/domain/usecases/create_content_usecase.dart';
import '../features/content_creation/domain/usecases/extract_text_usecase.dart';
import '../features/content_creation/domain/usecases/check_then_humanize_usecase.dart';
import '../features/content_creation/domain/usecases/get_saved_contents_usecase.dart';
import '../features/content_creation/presentation/task_selection/bloc/task_selection_bloc.dart';
import '../features/content_creation/presentation/task_form/bloc/task_form_bloc.dart';
import '../features/content_creation/presentation/content_result/bloc/content_result_bloc.dart';

// Quality Imports
import '../features/quality/data/datasources/quality_remote_datasource.dart';
import '../features/quality/data/repositories/quality_repository_impl.dart';
import '../features/quality/domain/repositories/quality_repository.dart';
import '../features/quality/domain/usecases/quality_usecases.dart';
import '../features/quality/presentation/bloc/quality_bloc.dart';

// Long Research Imports
import '../features/long_research/data/datasources/long_research_remote_datasource.dart';
import '../features/long_research/data/repositories/long_research_repository_impl.dart';
import '../features/long_research/domain/repositories/long_research_repository.dart';
import '../features/long_research/presentation/bloc/research_bloc.dart';

// Excel Versioner Imports
import '../features/excel_versioner/data/datasources/excel_versioner_remote_datasource.dart';
import '../features/excel_versioner/data/repositories/excel_versioner_repository_impl.dart';
import '../features/excel_versioner/domain/repositories/excel_versioner_repository.dart';
import '../features/excel_versioner/domain/usecases/generate_excel_versions_usecase.dart';
import '../features/excel_versioner/presentation/bloc/excel_versioner_bloc.dart';

// Agency Imports
import '../features/agency/data/datasources/agency_remote_datasource.dart';
import '../features/agency/data/repositories/agency_repository_impl.dart';
import '../features/agency/domain/repositories/agency_repository.dart';
import '../features/agency/presentation/bloc/agency_bloc/agency_bloc.dart';

// Publishing Imports
import '../features/publishing/data/datasources/publishing_remote_datasource.dart';
import '../features/publishing/data/repositories/publishing_repository_impl.dart';
import '../features/publishing/domain/repositories/publishing_repository.dart';
import '../features/publishing/presentation/bloc/publishing_bloc/publishing_bloc.dart';

// Academic Workspace Imports
import '../features/academic_workspace/data/datasources/academic_project_remote_datasource.dart';
import '../features/academic_workspace/data/repositories/academic_project_repository_impl.dart';
import '../features/academic_workspace/domain/repositories/academic_project_repository.dart';
import '../features/academic_workspace/presentation/bloc/academic_workspace_bloc/academic_workspace_bloc.dart';

part 'injection_core.dart';
part 'injection_smart_parser.dart';
part 'injection_content_creation.dart';
part 'injection_quality.dart';
part 'injection_long_research.dart';
part 'injection_agency.dart';
part 'injection_excel_versioner.dart';
part 'injection_publishing.dart';
part 'injection_academic_workspace.dart';

enum Environment { dev, prod }

final locator = GetIt.instance; // Replaced sl with locator for Onyx parity

Future<void> init({Environment env = Environment.prod}) async {
  if (env == Environment.dev) {
    locator.registerLazySingleton<Configuration>(() => MasarProDevConfig());
  } else {
    locator.registerLazySingleton<Configuration>(() => MasarProProdConfig());
  }

  _initCore();
  _initAgency();
  _initSmartParser();
  _initContentCreation();
  _initQuality();
  _initLongResearch();
  _initExcelVersioner();
  _initPublishing();
  _initAcademicWorkspace();
}
