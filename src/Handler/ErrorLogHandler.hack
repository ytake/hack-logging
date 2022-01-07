namespace HackLogging\Handler;

use namespace HackLogging;
use function error_log;

final class ErrorLogHandler extends AbstractProcessingHandler {
  <<__Override>>
  protected async function writeAsync(
    HackLogging\RecordShape $record,
  ): Awaitable<void> {
    $formatted = Shapes::idx($record, 'formatted', '');
    error_log($formatted);
  }
}
