namespace HackLogging\Handler;

use type HackLogging\LogLevel;
use type HackLogging\RecordShape;
use namespace HH\Lib\Experimental\File;

class FilesystemHandler extends AbstractProcessingHandler {

  public function __construct(
    private File\CloseableWriteHandle $writeHandler,
    protected LogLevel $level = LogLevel::DEBUG,
    protected bool $bubble = true,
    protected ?int $filePermission = null,
    protected ?File\LockType $fileLockType = null
  ) {
    parent::__construct($level, $bubble);
  }

  <<__Override>>
  public async function closeAsync(): Awaitable<void> {
    return await $this->writeHandler->closeAsync();
  }

  <<__Override>>
  protected async function writeAsync(RecordShape $record): Awaitable<void> {
    $formatted = Shapes::idx($record, 'formatted', '');
    if($this->fileLockType is nonnull) {
      using ($fl = $this->writeHandler->lock($this->fileLockType)) {
        await $this->writeHandler->writeAsync($formatted);
      }
    }
    await $this->writeHandler->writeAsync($formatted);
  }
}
