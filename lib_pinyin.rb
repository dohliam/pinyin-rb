class Py_Converter
  def initialize(base_rom=0)
    @dict = read_dict(base_rom)
  end

  def convert_syllable(word, method, mods=nil)
    w = @dict[word.downcase]
    if w
      syllable = w[method]
      if mods
        get_modifications(syllable, mods)
      else
        method == 13 ? w : syllable
      end
    else
      word
    end
  end

  def read_dict(base_rom=0)
    pwd = Dir.pwd
    Dir.chdir(File.dirname(__FILE__))
    file = File.read("pinyin/pinyinbiao")
    Dir.chdir(pwd)
    dict = {}
    file.each_line do |line|
      line_split = line.chomp.split("\t")
      dict[line_split[base_rom]] = line_split
    end
    dict
  end

  def convert_line(line, method, mods=nil)
    line_array = line.split(/\s+/)
    result = ""
    if method == 13
      13.times do |c|
        line_array.each do |word|
          result << convert_syllable(word, c, mods) + " "
        end
        result << "\n"
      end
    else
      line_array.each do |word|
        result << convert_syllable(word, method, mods) + " "
      end
    end
    result.gsub(/\s+\Z/, "")
  end

  def check_syllable(word)
    w = @dict[word.downcase]
    w ? true : false
  end

  def to_numerals(syllable)
    sup_hash = {
      "¹" => "1", "²" => "2", "³" => "3",
      "⁴" => "4", "⁵" => "5", "⁶" => "6",
      "⁷" => "7", "⁸" => "8", "⁹" => "9"
    }
    syllable.gsub!(/([¹²³⁴⁵⁶⁷⁸⁹])/) { |s| sup_hash[s] }
  end

  def normalize_pinyin(syllable)
    syllable.gsub!(/·/, "")
  end

  def get_modifications(syllable, mods)
    normalize_pinyin(syllable) if mods[:normalize]
    to_numerals(syllable) if mods[:numerals]
    syllable
  end
end

#1	2	3	4	5	6	7	8	9	10	11	12	13
#带数	带调	注音符号	威妥玛拼音	注音二式	耶鲁	通用拼音	国语罗马字	拼声拼音	俄文拼音	汉字（繁体）	汉字（简体）	国际音标
#hanyupinyin	daidiao	zhuyin	wadegiles	zhuyin2	yale	tongyong	gylmz	pinsheng	ewen	fanti	jianti	gjyb
