// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_azure_cosmos_db/otel_azure_cosmos_db.dart';

/// Traces Azure Cosmos DB calls with OpenTelemetry.
///
/// `otel_azure_cosmos_db` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Azure Cosmos DB call in
/// [tracedAzureCosmosDb]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'azure-cosmos-db-example');

  // Wraps an Azure Cosmos DB call in a CLIENT span.
  final azureCosmosDbId = await tracedAzureCosmosDb<String>(
    operation: 'database.create',
    invoke: () async {
      // Make the Azure Cosmos DB call here, then report what it returned.
      const id = 'azure_cosmos_db_8f3a2c';
      return const AzureCosmosDbCallResult(
          value: id,
          result: AzureCosmosDbResult(
              accountEndpoint: 'https://<account>.documents.azure.com',
              apiKind: 'sql',
              database: 'example',
              container: 'example',
              partitionKey: 'orders/2026/inv-1042.pdf',
              partitionKeyKind: 'Hash',
              consistencyLevel: 'Strong',
              itemId: 'item_8f3a2c',
              activityId: 'activity_8f3a2c',
              requestBytes: 512,
              responseBytes: 512,
              itemCount: 3,
              requestCharge: 0.5,
              consumedRus: 0.5,
              queryRus: 0.5,
              continuationToken: true,
              indexUtilization: true,
              crossPartition: true,
              retryAfterMs: 120,
              errorCode: '404',
              errorSubStatus: '1002',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedAzureCosmosDb database.create returned $azureCosmosDbId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAzureCosmosDbInstrumentationAsync.
  await runWithoutAzureCosmosDbInstrumentationAsync(
    () => tracedAzureCosmosDb<String>(
      operation: 'database.create',
      invoke: () async {
        const id = 'azure_cosmos_db_8f3a2c';
        return const AzureCosmosDbCallResult(
            value: id,
            result: AzureCosmosDbResult(
                accountEndpoint: 'https://<account>.documents.azure.com',
                apiKind: 'sql',
                database: 'example',
                container: 'example',
                partitionKey: 'orders/2026/inv-1042.pdf',
                partitionKeyKind: 'Hash',
                consistencyLevel: 'Strong',
                itemId: 'item_8f3a2c',
                activityId: 'activity_8f3a2c',
                requestBytes: 512,
                responseBytes: 512,
                itemCount: 3,
                requestCharge: 0.5,
                consumedRus: 0.5,
                queryRus: 0.5,
                continuationToken: true,
                indexUtilization: true,
                crossPartition: true,
                retryAfterMs: 120,
                errorCode: '404',
                errorSubStatus: '1002',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
