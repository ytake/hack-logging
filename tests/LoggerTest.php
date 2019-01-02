<?hh // strict

use type Facebook\HackTest\HackTest;
use type HackLogging\Logger;
use namespace HH\Lib\{C, Vec};
use function Facebook\FBExpect\expect;

final class LoggerTest extends HackTest {

  
  public function testShouldBe(): void {
    $v = vec[1,2,3,4,5];
    var_dump(C\firstx($v), Vec\drop($v, 1));
  }
}
