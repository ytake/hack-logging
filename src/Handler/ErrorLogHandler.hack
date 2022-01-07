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

  <<__Override>>
  protected function getDefaultFormatter()[]: HackLogging\Formatter\FormatterInterface {
    return new HackLogging\Formatter\LineFormatter(
      '[%datetime%] %channel%.%level_name%: %message% %context% %extra%',
    );
  }
}
