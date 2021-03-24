# pinyin-rb - Mandarin Chinese transcription conversion in Ruby

This repository contains a Ruby library and example conversion tool that makes use of the open-licensed [Pinyin Database](https://github.com/kfcd/pinyin) to convert between 13 different Mandarin Chinese transcription systems and variants.

* [1 Features](#features)
* [2 Included transcription systems](#included-transcription-systems)
* [3 Requirements](#requirements)
* [4 Usage](#usage)
  * [4.1 lib_pinyin](#lib_pinyin)
    * [4.1.1 converting syllables](#converting-syllables)
  * [4.2 convert_pinyin](#convert_pinyin)
    * [4.2.1 Basic usage](#basic-usage)
    * [4.2.2 Checking input validity](#checking-input-validity)
    * [4.2.3 Modifying the output](#modifying-the-output)
    * [4.2.4 Options](#options)
* [5 To do](#to-do)
* [6 See also](#see-also)
* [7 License](#license)

## Features

* Converts to and from any Mandarin Chinese transcription scheme (including IPA)
* Can convert single and multiple words / whole lines of romanized text
* Handles mixed input (non-Mandarin text is ignored)
* Converter script ready to use on the command-line -- or include the library in your own code

## Included transcription systems

In total 13 Mandarin Chinese transcription systems (or, less accurately, _romanization systems_ -- since not all of them make use of the Roman alphabet) are available for conversion using this library. Each system is identified by a number (`0-10`); this number is also used for identifying the "to" and "from" transcription systems to use while converting text.

Index | Name | Chinese | Variant
----- | ---- | ------- | -------
`0` | [Hanyu Pinyin](https://en.wikipedia.org/wiki/Pinyin) | 漢語拼音 | Tone numbers
`1` | Hanyu Pinyin | | Tone diacritics
`2` | [Bopomofo](https://en.wikipedia.org/wiki/Bopomofo) | 注音符號 | 
`3` | [Wade-Giles](https://en.wikipedia.org/wiki/Wade%E2%80%93Giles) | 威妥瑪拼音 | 
`4` | [MPS II](https://en.wikipedia.org/wiki/Mandarin_Phonetic_Symbols_II)
`5` | [Yale](https://en.wikipedia.org/wiki/Yale_romanization_of_Mandarin) | 耶魯拼音 |
`6` | [Tongyong](https://en.wikipedia.org/wiki/Tongyong_Pinyin) | 通用拼音 | 
`7` | [Gwoyeu Romatzyh](https://en.wikipedia.org/wiki/Gwoyeu_Romatzyh) | 國語羅馬字 | 
`8` | [TOP](http://terrywaltz.com/terry-waltz-tprs-tonally-orthographic-pinyin.php) | 拼聲拼音 | 
`9` | [Palladius](https://en.wikipedia.org/wiki/Cyrillization_of_Chinese) | 俄文拼音 | 
`10` | Character Exemplars | 漢字示例 | Traditional
`11` | Character Exemplars | 漢字示例 | Simplified
`12` | [IPA](https://en.wikipedia.org/wiki/International_Phonetic_Alphabet) | 國際音標 | 

Note: The Hanyu Pinyin variant with tone diacritics uses a middle dot (`·`) by default to indicate the fifth (neutral) tone. However, this library includes an optional method to print the Pinyin transcription without this dot (see [below](#modifying-the-output) for details).

## Requirements

This library makes use of the latest version of the [Pinyin database](https://github.com/kfcd/pinyin), and expects a file called `pinyinbiao` containing the conversion data to be located in a `pinyin` folder in the project root directory. There a number of ways to do this:

* _Easiest method_: Run the `update_database.rb` script to get the latest version of the script
  * Instructions: In the project root directory, enter the following command: `./update_database.rb`
  * If the current version of the database is different than the one on your machine, your local copy will be updated
* Download the file directly from the Pinyin project [here](https://github.com/kfcd/pinyin/blob/master/pinyinbiao).
  * Make sure to create a directory called `pinyin` in the project root and copy the file to that directory
* If you have `git` installed, you can clone the database into the root project folder using the following command: `git clone https://github.com/kfcd/pinyin.git
* Download the Pinyin project into a separate location and create a symlink in the current project directory

There are no other special requirements other than a working version of Ruby.

## Usage

This project can be used either as a library (`lib_pinyin.rb`) or as a command-line script (`convert_pinyin.rb`). Details for both types of usage can be found below.

### lib_pinyin

To use the library, make sure to `require` the library file, e.g.:

```ruby
require_relative 'lib_pinyin.rb'
```

Before you can convert text, you need to initialize a `Converter` object:

```ruby
conv = Py_Converter.new
```

By default, this initializes a conversion dictionary that works from Hanyu Pinyin to any other transcription system.

To use a different source transcription system, just specify the corresponding index number as an argument when initializing the `Converter` object, e.g.:

```ruby
conv = Py_Converter.new(2)
# => This converts from Bopomofo to any other system
```

You can then convert any string of text using the `convert_line` method, which takes a string and an integer representing the target transcription system as arguments:

```ruby
pinyin = "Bopomofo to Hanyu Pinyin conversion: ㄏㄢˋ ㄩˇ ㄆㄧㄣ ㄧㄣ ㄓㄨㄢˇ ㄏㄨㄢˋ"
puts conv.convert_line(pinyin, 1)
# => Bopomofo to Hanyu Pinyin conversion: hàn yǔ pīn yīn zhuǎn huàn
```

Tip: If you provide `13` as the index number when converting, the string will be translated into all of the available systems sequentially, e.g.:

```ruby
pinyin = "han4 yu3 pin1 yin1 fang1 an4 yi1 lan3"
puts conv.convert_line(pinyin, 13)
# => han4 yu3 pin1 yin1 fang1 an4 yi1 lan3 
# => hàn yǔ pīn yīn fāng àn yī lǎn 
# => ㄏㄢˋ ㄩˇ ㄆㄧㄣ ㄧㄣ ㄈㄤ ㄢˋ ㄧ ㄌㄢˇ 
# => han⁴ yü³ p'in¹ yin¹ fang¹ an⁴ i¹ lan³ 
# => han4 yu3 pin1 yin1 fang1 an4 yi1 lan3 
# => hàn yǔ pīn yīn fāng àn yī lǎn 
# => hanˋ yuˇ pin yin fang anˋ yi lanˇ 
# => hann yeu pin in fang ann i laan 
# => Han yu PIN YIN FANG An YI lan 
# => хань⁴ юй³ пинь¹ инь¹ фан¹ ань⁴ и¹ лань³ 
# => 汗⁴ 于³ 品¹ 因¹ 方¹ 安⁴ 一¹ 懶³ 
# => 汗⁴ 于³ 品¹ 因¹ 方¹ 安⁴ 一¹ 懒³ 
# => xan˥˩ y˨˩˦ pʰɪn˥˥ ɪn˥˥ fɑŋ˥˥ an˥˩ i˥˥ lan˨˩˦
```

The `Converter` class has a built-in method for checking if a given string is a valid syllable in any of the available Mandarin Chinese transcription systems:

```ruby
conv = Py_Converter.new
# checks against syllables in Hanyu Pinyin (numerals) by default

word = "xiang1"
puts conv.check_syllable(word)
# => true

word = "xiangg1"
puts conv.check_syllable(word)
# => false
```

To check syllables in any other transcription system, just specify it when initializing the `Converter` class:

```ruby
conv = Py_Converter.new(2)
# checks valid Bopomofo syllables

word = "ㄕㄨㄤㄤ"
puts conv.check_syllable(word)
# => false

word = "ㄕㄨㄤ"
puts conv.check_syllable(word)
# => true
```

#### converting syllables

You can convert individual syllables using the `convert_syllable` method of the `Converter` class. This method requires two arguments: a string consisting of a single romanized syllable and an integer representing the index number of the target transcription system.

For example, to convert a syllable in Hanyu Pinyin into IPA:

```ruby
conv = Py_Converter.new
p conv.convert_syllable("shuang1", 12)
# => "ʂwɑŋ˥˥"
```

To convert from a different source transcription system, just provide the corresponding index number when initializing the Converter object.

For example, to convert IPA into Bopomofo:

```ruby
@conv = Py_Converter.new(12)
p @conv.convert_syllable("ʂwɑŋ˥˥", 2)
# => "ㄕㄨㄤ"
```

If `13` is passed as the final argument to the `convert_syllable` method, it will return an array containing all of the possible transcriptions of the given syllable:

```ruby
conv = Py_Converter.new
p conv.convert_syllable("shuang1", 13)
# => ["shuang1 ", "shuāng ", "ㄕㄨㄤ ", "shuang¹ ", "shuang1 ", "shwāng ", "shuang ", "shuang ", "SHUANG ", "шуан¹ ", "雙¹ ", "双¹ ", "ʂwɑŋ˥˥"]
```

### convert_pinyin

The `convert_pinyin.rb` file found in the root directory is a simple script that demonstrates the use of the `lib_pinyin` library. It allows for quick and easy conversion between arbitrary Mandarin Chinese transcription systems on the command-line.

#### Basic usage

```bash
./convert_pinyin.rb -i "This is a test: Han4 yu3 pin1 yin1 fang1 an4 yi1 lan3"
# => This is a test: hàn yǔ pīn yīn fāng àn yī lǎn
```

The above example converts the Mandarin Chinese romanization in the provided sentence from Hanyu Pinyin (with numerals) into Hanyu Pinyin with diacritics. All of the text that is not recognizable as Mandarin Chinese romanization (e.g., all of the English text before the colon in the provided sentence) is ignored.

To convert the text into Bopomofo instead, just provide the index number for Bopomofo (i.e., `2` -- see [list above](#included-transcription-systems)) using the `-t` (`--target`) option:

```bash
./convert_pinyin.rb -i "This is a test: Han4 yu3 pin1 yin1 fang1 an4 yi1 lan3" -t 2
# => This is a test: ㄏㄢˋ ㄩˇ ㄆㄧㄣ ㄧㄣ ㄈㄤ ㄢˋ ㄧ ㄌㄢˇ
```

As can be seen, the text has now been converted into Bopomofo orthography. Conversion into other systems is equally easy -- just replace `2` above with the index number of the system you wish to use for output.

To convert from a different source transcription system (e.g., to convert from Wade-Giles to Yale, or from Yale to Hanyu Pinyin), provide the source system index number as a parameter using the `-s` (`--source`) option. The example below converts from Bopomofo to Hanyu Pinyin with diacritics:

```bash
./convert_pinyin.rb -i "This is a test: ㄏㄢˋ ㄩˇ ㄆㄧㄣ ㄧㄣ ㄈㄤ ㄢˋ ㄧ ㄌㄢˇ" -s 2
# => This is a test: hàn yǔ pīn yīn fāng àn yī lǎn
```

#### Checking input validity

Invalid syllables can be identified using the `-c` (`--check`) option. This checks each word in the input string and outputs a list of words that are not recognizable as valid Mandarin Chinese syllables in the given transcription system:

```bash
./convert_pinyin.rb -i "This is a test: Han4 yu3 pin1 yin1 fang1 an4 yi1 lan3" -c
# => This
# => is
# => a
# => test:
```

The output in the above example contains words that are not valid syllables in Hanyu Pinyin romanization (the default, since no other system was specified). To use a different transcription system just provide the appropriate index number using the `-s` option. For example, the command below checks for invalid syllables in Wade-Giles:

```bash
./convert_pinyin.rb -i "This is a test: han⁴ yü³ p'in¹ yin¹ fang¹ an⁴ i¹ laan³" -c -s 3
# => This
# => is
# => a
# => test:
# => laan³
```

In the example above, the output contains (apart from English) the syllable `laan³`, because it is not a valid syllable in the Wade-Giles system.

#### Modifying the output

The output transcription can be further modified using optional command-line flags, for example to convert regular tone numerals to superscript numerals (Unicode), or to revert to the dotless-Hanyu Pinyin transcription.

* **Numerals instead of superscript tone numbers**: Several transcription systems use superscript numbers to indicate tones in Mandarin Chinese. These may be converted into normal numeral form for ease of typing or for data consistency. To use numerals instead of superscript, use the `-N` (`--numerals`) option with any superscript-using transcription system. For example, this would convert `siu² chak⁷ si³` to `siu2 chak7 si3`.
* **Pinyin normalization**: To use a dotless transcription instead of the default which uses a middle dot on fifth/zero/neutral tones, use the `-n` (`--normalize`) option. For example, this will convert `nǐ hǎo ma·` to `nǐ hǎo ma`.

#### Options

The following options can be provided to `convert_pinyin.rb` to control the conversion process:

* `-c`, `--check`: _Check if input contains invalid syllables_
* `-i`, `--input STRING`: _Input string to be converted_
* `-f`, `--filename FILE`: _Provide file for conversion_
* `-n`, `--normalize`: _Normalize Pinyin (removes marker from fifth tone)_
* `-N`, `--numerals`: _Print all superscript tone numbers as numerals_
* `-s`, `--source INDEX`: _Provide index number of transcription system to convert from_
* `-t`, `--target INDEX`: _Provide index number of transcription system to convert into_

## To do

* Optional HTML output
* Handle pipes as input
* Accept numerals as input instead of superscript tone numbers

## See also

* [Pinyin database](https://github.com/kfcd/pinyin)
* [pinyin-js](https://github.com/dohliam/pinyin-js) - Online Mandarin Chinese Romanization Converter

## License

* Transcription system data: [CC BY](https://github.com/kfcd/pinyin/blob/master/LICENSE)
* All other code: [MIT](LICENSE)
