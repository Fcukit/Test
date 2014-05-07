#Испытательное задание

#encoding: utf-8
require 'active_support/core_ext'

#метод парсинга даты и времени
def parse_date_time(str)
  day = str[0] + str[1]
  month = str[3] + str[4]
  year = str[6] + str[7] +str[8] + str[9]
  hour = str[11] + str[12]
  min = str[14] + str[15]
  sec = str[17] + str[18]
  return Time.mktime(year, month, day, hour, min, sec)
end

#инициализация переменных
file_name = ARGV[1] #имя текстового файла
end_time_param = ARGV[3].to_i #значение параметра -t
final_time = 0 #время окончания сбора данных 
queries = [] #список запросов, попавших в кэш
all_queries = [] #список всех обработанных запросов
uniq_counter = 0 #счетчик уникальных запросов

#читаем исходный файл
file = File.readlines(file_name);
file.map! {|element| element.chomp}

#задаем время окончания сбора данных
final_time = parse_date_time(file[0]).to_i + end_time_param

#парсим дату и время
file.each { |str|
    now_time = parse_date_time(str)
    query = ""      #текст запроса
    pointer = 20    #с этой позиции начинается текст запроса
    #парсим текст запроса
    begin
      if pointer < str.length
        query += str[pointer]
        pointer = pointer + 1
      end
    end until pointer == str.length
    
    query = query.mb_chars.downcase.to_s
    
    #добавляем текст запроса в список
    if now_time.to_i > final_time.to_i    
      all_queries.push(query)
    else
      queries.push(query)
      all_queries.push(query)
    end
}

#взвешенный список всех запросов
sorted_queries = Hash.new(0)
all_queries.each{ |l| sorted_queries[l] += 1 }

#поиск уникальных запросов
sorted_queries.each do |key, value|
  uniq_counter += 1 if value == 1
end

#взвешенный список обработанных запросов
cache_list = Hash.new(0)
queries.each{ |l| cache_list[l] += 1}
cache_list.default = 0

#считаем количество НЕпопаданий запросов в кэш
miss_ratio = 0
sorted_queries.each_key do |key|
  miss_ratio += 1 if cache_list[key] == 0
end

#вероятность попадания в кэш
hit_ratio = (1.0 - (miss_ratio.to_f / file.size)).round 4

#вывод
puts "Queries total: #{file.size}"
puts "Queries uniq: #{uniq_counter}"
puts "Queries max size: #{queries.size}"
puts "Cache hit ratio: #{hit_ratio}"
