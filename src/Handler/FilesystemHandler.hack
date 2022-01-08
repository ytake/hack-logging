namespace HackLogging\Handler;

use namespace HackLogging;
use namespace HH\Lib\File;

class FilesystemHandler extends AbstractProcessingHandler {
  public function __construct(
    private File\CloseableWriteHandle $writeHandler,
    protected HackLogging\LogLevel $level = HackLogging\LogLevel::DEBUG,
    bool $bubble = true,
    protected ?int $filePermission = null,
    protected ?File\LockType $fileLockType = null
  )[] {
    parent::__construct($level, $bubble);
  }

  <<__Override>>
  public async function closeAsync(): Awaitable<void> {
    return $this->writeHandler->close();
  }

  <<__Override>>
  protected async function writeAsync(
    HackLogging\RecordShape $record,
  ): Awaitable<void> {
    $formatted = Shapes::idx($record, 'formatted', '');
    if($this->fileLockType is nonnull) {
      using ($_fl = $this->writeHandler->lock($this->fileLockType)) {
        await $this->writeHandler->writeAllAsync($formatted);
      }
    }
    await $this->writeHandler->writeAllAsync($formatted);
  }
}
