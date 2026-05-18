// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_azure_cosmos_db/otel_azure_cosmos_db.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_azure_cosmos_db-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('query.execute records RU + cross-partition', () async {
    await tracedAzureCosmosDb<String>(
      operation: 'query.execute',
      invoke: () async => const AzureCosmosDbCallResult(
        value: 'ok',
        result: AzureCosmosDbResult(
          apiKind: 'sql',
          database: 'app',
          container: 'orders',
          consistencyLevel: 'Session',
          activityId: 'aid_1',
          itemCount: 50,
          consumedRus: 12.5,
          queryRus: 8.2,
          crossPartition: true,
          continuationToken: true,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('azure_cosmos_db query.execute')!);
    expect(a['azure_cosmos_db.consumed_rus'], 12.5);
    expect(a['azure_cosmos_db.cross_partition'], true);
    expect(a['azure_cosmos_db.consistency_level'], 'Session');
  });

  test('throttled 429 with retry-after sets span error', () async {
    await tracedAzureCosmosDb<String>(
      operation: 'item.create',
      invoke: () async => const AzureCosmosDbCallResult(
        value: 'ok',
        result: AzureCosmosDbResult(
          errorCode: '429',
          errorSubStatus: '1007',
          retryAfterMs: 1500,
          statusCode: 429,
        ),
      ),
    );
    final s = spans.findSpanByName('azure_cosmos_db item.create')!;
    expect(s.status, SpanStatusCode.Error);
    expect(attrsOf(s)['azure_cosmos_db.retry_after_ms'], 1500);
  });

  test('mongo.find on Mongo API kind', () async {
    await tracedAzureCosmosDb<String>(
      operation: 'mongo.find',
      invoke: () async => const AzureCosmosDbCallResult(
        value: 'ok',
        result: AzureCosmosDbResult(
          apiKind: 'mongo',
          database: 'app',
          container: 'users',
          itemCount: 100,
          consumedRus: 5.4,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('azure_cosmos_db mongo.find')!);
    expect(a['azure_cosmos_db.api.kind'], 'mongo');
  });

  test('suppression skips spans', () async {
    await runWithoutAzureCosmosDbInstrumentationAsync(() async {
      await tracedAzureCosmosDb<String>(
        operation: 'database.readAll',
        invoke: () async => const AzureCosmosDbCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('azure_cosmos_db '), isEmpty);
  });
}
