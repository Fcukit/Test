#Испытательное задание

#encoding: utf-8
require 'active_support/core_ext'

#Метод парсинга даты и времени
def parse_date_time(str)
  day = str[0] + str[1]
  month = str[3] + str[4]
  year = str[6] + str[7] +str[8] + str[9]
  hour = str[11] + str[12]
  min = str[14] + str[15]
  sec = str[17] + str[18]
  return Time.mktime(year, month, day, hour, min, sec)
end

#Инициализация переменных
file_name = ARGV[1] #имя текстового файла
cache_live_time = ARGV[3].to_i #значение параметра -t

all_queries = [] #список всех обработанных запросов
uniq_counter = 0 #счетчик уникальных запросов
max_size_cache = 0 #размер кэша
hit = 0 #вероятность попадания в кэш

#читаем исходный файл
file = File.readlines(file_name);
file.map! {|element| element.chomp}

#Взвешенные списки запросов
  in_cache_queries = Hash.new(0)
  all_sorted_queries = Hash.new(0)    
#Парсим дату и время
file.each { |str|
    now_time = parse_date_time(str).to_i
    query = ""      #текст запроса
    pointer = 20    #с этой позиции начинается текст запроса

    #Парсим текст запроса
    begin
      if pointer < str.length
        query += str[pointer]
        pointer = pointer + 1
      end
    end until pointer == str.length
    
    #Получаем текст запроса
    query = query.mb_chars.downcase.to_s.strip
    all_queries.push(query)

    #Ищем запрос в кэше   
    if in_cache_queries[query] == 0 #запроса нет в кэше
      in_cache_queries[query] = now_time 
      max_size_cache += 1 #размер кэша
    else
      #Запрос есть в кэше, но смотрим но его время хранения
      if (now_time - cache_live_time - in_cache_queries[query]) > 0
        in_cache_queries[query] = now_time      
      else
        #Время хранения запроса в кэше еще не истекло
        hit += 1 
      end   
    end
}

#Поиск уникальных запросов
all_queries.each{|q| all_sorted_queries[q] += 1}
all_sorted_queries.each do |key, value|
  uniq_counter += 1 if value == 1
end

#Вероятность попадания в кэш
hit = (hit.to_f / file.size).round 4

#Вывод
puts "Queries total: #{max_size_cache}"
puts "Queries uniq: #{uniq_counter}"
puts "Queries max size: #{all_queries.size}"
puts "Cache hit ratio: #{hit}"
