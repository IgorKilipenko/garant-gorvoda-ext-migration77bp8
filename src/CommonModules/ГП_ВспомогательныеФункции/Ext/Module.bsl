﻿#Область ПрограммныйИнтерфейс

// Параметры:
//  Контейнер - Произвольный
//  Ключ - Строка, Произвольный
//  ЗначениеПоУмолчанию - Произвольный
// Возвращаемое значение:
//  - Произвольный
Функция ПолучитьЗначениеСвойстваКонтейнера(Знач Контейнер, Знач Ключ, Знач ЗначениеПоУмолчанию = Неопределено) Экспорт
    РезультатФункции = ЗначениеПоУмолчанию;

    ТипКонтейнера = ТипЗнч(Контейнер);

    // Для структуры
    Если ТипКонтейнера = Тип("Структура") ИЛИ ТипКонтейнера = Тип("ФиксированнаяСтруктура") Тогда
        Если Контейнер.Свойство(Ключ) Тогда
            РезультатФункции = Контейнер[Ключ];
        КонецЕсли;

        Возврат РезультатФункции;
    КонецЕсли;

    // Общий случай
    Попытка
        РезультатФункции = Контейнер[Ключ];
    Исключение
        РезультатФункции = ЗначениеПоУмолчанию;
    КонецПопытки;

    Возврат РезультатФункции;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс
