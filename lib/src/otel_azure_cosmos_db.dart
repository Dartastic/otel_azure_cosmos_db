// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_azure_cosmos_db_suppression.dart';

const _tracerName = 'dartastic_otel_libs_azure_cosmos_db';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class AzureCosmosDbResult {
  /// Creates a result.
  const AzureCosmosDbResult({
    this.accountEndpoint,
    this.apiKind,
    this.database,
    this.container,
    this.partitionKey,
    this.partitionKeyKind,
    this.consistencyLevel,
    this.itemId,
    this.activityId,
    this.requestBytes,
    this.responseBytes,
    this.itemCount,
    this.requestCharge,
    this.consumedRus,
    this.queryRus,
    this.continuationToken,
    this.indexUtilization,
    this.crossPartition,
    this.retryAfterMs,
    this.errorCode,
    this.errorSubStatus,
    this.errorMessage,
    this.statusCode,
  });

  /// `https://<account>.documents.azure.com` or `<account>.documents.azure.com`.
  final String? accountEndpoint;

  /// `sql` (Core/NoSQL), `mongo`, `cassandra`, `gremlin`, `table`, `pgvector`.
  final String? apiKind;

  /// Database name.
  final String? database;

  /// Container / collection / graph / table name.
  final String? container;

  final String? partitionKey;

  /// `Hash`, `Range`, `MultiHash`.
  final String? partitionKeyKind;

  /// `Strong`, `BoundedStaleness`, `Session`, `ConsistentPrefix`, `Eventual`.
  final String? consistencyLevel;

  final String? itemId;

  /// Cosmos `activityId` (server-side trace id).
  final String? activityId;

  final int? requestBytes;
  final int? responseBytes;

  /// Number of items returned / written.
  final int? itemCount;

  /// `x-ms-request-charge` for this individual request.
  final double? requestCharge;

  /// Aggregated RU consumption for the call.
  final double? consumedRus;

  /// Subset of consumed RU spent on query plan + execution.
  final double? queryRus;

  /// Pagination continuation token presence (we don't log the value).
  final bool? continuationToken;

  /// `x-ms-cosmos-index-utilization` provided.
  final bool? indexUtilization;

  /// Query enabled `EnableCrossPartitionQuery`.
  final bool? crossPartition;

  /// `x-ms-retry-after-ms` on 429.
  final int? retryAfterMs;

  /// Cosmos HTTP error code (numeric, `404`, `409`, `429`, `503`, ...).
  final String? errorCode;

  /// Cosmos sub-status code (`1002` ConflictWithControlPlane,
  /// `1007` AggregateThrottle, `3200` ServiceUnavailable, ...).
  final String? errorSubStatus;
  final String? errorMessage;
  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AzureCosmosDbCallResult<T> {
  /// Creates a call result.
  const AzureCosmosDbCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AzureCosmosDbResult? result;
}

/// Wraps an Azure Cosmos DB call in a CLIENT span. [operation] is one of
/// `database.create`, `database.delete`, `database.read`,
/// `database.readAll`, `container.create`, `container.delete`,
/// `container.read`, `container.replaceThroughput`,
/// `container.readThroughput`, `item.create`, `item.upsert`,
/// `item.replace`, `item.patch`, `item.delete`, `item.read`,
/// `item.readAll`, `item.bulk`, `query.execute`, `query.feedIterator`,
/// `changeFeed.read`, `storedProcedure.execute`, `udf.create`,
/// `udf.delete`, `trigger.create`, `trigger.delete`,
/// `transactionalBatch.execute`, `mongo.find`, `mongo.insertOne`,
/// `mongo.updateOne`, `mongo.deleteOne`, `cassandra.execute`,
/// `gremlin.submit`, `table.upsert`, `table.query`.
Future<T> tracedAzureCosmosDb<T>({
  required String operation,
  required Future<AzureCosmosDbCallResult<T>> Function() invoke,
}) async {
  if (azureCosmosDbInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'azure_cosmos_db',
    'rpc.method': operation,
    'azure_cosmos_db.operation': operation,
  };

  final span = _tracer().startSpan(
    'azure_cosmos_db $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.accountEndpoint != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.account.endpoint',
          res.accountEndpoint!,
        ));
      }
      if (res.apiKind != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.api.kind',
          res.apiKind!,
        ));
      }
      if (res.database != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.database',
          res.database!,
        ));
      }
      if (res.container != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.container',
          res.container!,
        ));
      }
      if (res.partitionKey != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.partition_key',
          res.partitionKey!,
        ));
      }
      if (res.partitionKeyKind != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.partition_key.kind',
          res.partitionKeyKind!,
        ));
      }
      if (res.consistencyLevel != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.consistency_level',
          res.consistencyLevel!,
        ));
      }
      if (res.itemId != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.item.id',
          res.itemId!,
        ));
      }
      if (res.activityId != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.activity.id',
          res.activityId!,
        ));
      }
      if (res.requestBytes != null) {
        extras.add(OTelAPI.attributeInt(
          'azure_cosmos_db.request.bytes',
          res.requestBytes!,
        ));
      }
      if (res.responseBytes != null) {
        extras.add(OTelAPI.attributeInt(
          'azure_cosmos_db.response.bytes',
          res.responseBytes!,
        ));
      }
      if (res.itemCount != null) {
        extras.add(OTelAPI.attributeInt(
          'azure_cosmos_db.item.count',
          res.itemCount!,
        ));
      }
      if (res.requestCharge != null) {
        extras.add(OTelAPI.attributeDouble(
          'azure_cosmos_db.request_charge_rus',
          res.requestCharge!,
        ));
      }
      if (res.consumedRus != null) {
        extras.add(OTelAPI.attributeDouble(
          'azure_cosmos_db.consumed_rus',
          res.consumedRus!,
        ));
      }
      if (res.queryRus != null) {
        extras.add(OTelAPI.attributeDouble(
          'azure_cosmos_db.query_rus',
          res.queryRus!,
        ));
      }
      if (res.continuationToken != null) {
        extras.add(OTelAPI.attributeBool(
          'azure_cosmos_db.continuation_token',
          res.continuationToken!,
        ));
      }
      if (res.indexUtilization != null) {
        extras.add(OTelAPI.attributeBool(
          'azure_cosmos_db.index_utilization',
          res.indexUtilization!,
        ));
      }
      if (res.crossPartition != null) {
        extras.add(OTelAPI.attributeBool(
          'azure_cosmos_db.cross_partition',
          res.crossPartition!,
        ));
      }
      if (res.retryAfterMs != null) {
        extras.add(OTelAPI.attributeInt(
          'azure_cosmos_db.retry_after_ms',
          res.retryAfterMs!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.error.code',
          res.errorCode!,
        ));
        span.setStatus(
          SpanStatusCode.Error,
          'Cosmos DB ${res.errorCode}',
        );
      }
      if (res.errorSubStatus != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.error.sub_status',
          res.errorSubStatus!,
        ));
      }
      if (res.errorMessage != null) {
        extras.add(OTelAPI.attributeString(
          'azure_cosmos_db.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Cosmos DB HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
