﻿// Гарант+ Килипенко 14.08.2024 [F00227047] перенос норм потребления из БП77 ++
#Область ПрограммныйИнтерфейс

// Выполняет чтение данных норм потребления (ГруппыПотребителей) (из БП 7.7) из файла и записывает
//  данные в регистр `ГП_НормыПотребленияБП77`
// Параметры:
//  ПараметрыЗагрузки - Структура
//      * ДвоичныеДанныеФайла - ДвоичныеДанные
//      * СохранятьСвязи - Булево - Если Ложь, установленные связи с Нормами потребления услуг
//                                      будут разорваны (поле `НормаПотребленияУслуг` будет установлено в значение пустая ссылка)
//  АдресХранилища - Строка, Неопределено
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * КоличествоЗаписанных - Число
//      * ТекстСообщения - Строка, Неопределено
//  - Неопределено
Функция ЗагрузитьДанныеНормПотребленийВРегистр(ПараметрыЗагрузки, АдресХранилища = Неопределено) Экспорт
    РезультатФункции = Новый Структура("Успех, КоличествоЗаписанных, ТекстСообщения", Ложь, 0);

    // Чтение данных из файла XML
    РезультатЧтенияДанных = ГП_МиграцияОбщегоНазначения.ПрочитатьДанныеИзФайлаXML(
            ПараметрыЗагрузки.ДвоичныеДанныеФайла, "ГруппаПотребителя");
    Если РезультатЧтенияДанных.Успех = Ложь Тогда
        РезультатФункции.ТекстСообщения = РезультатЧтенияДанных.ТекстСообщения;
        Возврат ГП_МиграцияОбщегоНазначения.ПоместитьВХранилищеИВернуть(РезультатФункции, АдресХранилища);
    КонецЕсли;

    // Проверка структуры данных
    Если ТипЗнч(РезультатЧтенияДанных.Данные) <> Тип("СписокXDTO") Тогда
        РезультатФункции.ТекстСообщения = "Ошибка структуры данных.";
        Возврат ГП_МиграцияОбщегоНазначения.ПоместитьВХранилищеИВернуть(РезультатФункции, АдресХранилища);
    КонецЕсли;

    // Запись данных в регистр
    НормыПотребленияБП77 = РезультатЧтенияДанных.Данные;
    РезультатЗаписи = ЗаписатьДанныеНормПотребленийВРегистр(НормыПотребленияБП77, ПараметрыЗагрузки.СохранятьСвязи);

    // Формирование результата
    РезультатФункции.Успех = РезультатЗаписи.Успех;
    РезультатФункции.ТекстСообщения = РезультатЗаписи.СообщениеОбОшибке;
    РезультатФункции.КоличествоЗаписанных = РезультатЗаписи.КоличествоЗаписанных;

    Возврат ГП_МиграцияОбщегоНазначения.ПоместитьВХранилищеИВернуть(РезультатФункции, АдресХранилища);
КонецФункции

// Устарела. Требует рефакторинг - объединить с `СоздатьНормыПотребленияГорячейВодыДляНаселения`
//
// Создает нормы потребления холодной воды по виду тарифа "для населения"
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * СозданныеНормыПотребления - Массив из СправочникСсылка.КВП_НормыПотребленияУслуг
//      * ТекстСообщения - Строка, Неопределено
Функция СоздатьНормыПотребленияХолоднойВодыДляНаселения() Экспорт
    РезультатФункции = Новый Структура("Успех, СозданныеНормыПотребления, ТекстСообщения", Истина, Новый Массив);

    ТаблицаДляСозданияНормПотребления = ПолучитьТаблицуДанныхДляСозданияНормПотребленияХВДляНаселения();

    УслугаХолодноеВодоснабжение = ГП_МиграцияОбщегоНазначения.ПолучитьУслугуХолодноеВодоснабжение().Ссылка;
    ЕдиницыИзмеренияЛитры = Справочники.КлассификаторЕдиницИзмерения.НайтиПоКоду("112");

    НачатьТранзакцию();
    Попытка
        Для Каждого НормаПотребленияБП77 Из ТаблицаДляСозданияНормПотребления Цикл
            НовыйНормаПотребленияОбъект = Справочники.КВП_НормыПотребленияУслуг.СоздатьЭлемент();
            НовыйНормаПотребленияОбъект.Наименование = НормаПотребленияБП77.Наименование;

            НовыйНормаПотребленияОбъект.Владелец = УслугаХолодноеВодоснабжение;
            НовыйНормаПотребленияОбъект.НормаНаЛицевойСчет = Истина;
            НовыйНормаПотребленияОбъект.ЕдиницаИзмерения = ЕдиницыИзмеренияЛитры;
            НовыйНормаПотребленияОбъект.ВариантНастройки = Перечисления.КВП_ВариантыНастроекРасчетаНормативовПотребления.Простой;
            НовыйНормаПотребленияОбъект.Основание = Перечисления.КВП_ОснованияНормПотребления.ОдинЧеловек;
            НовыйНормаПотребленияОбъект.ВидЖильцов = Перечисления.УПЖКХ_ВидыЖильцов.Зарегистрированные;
            НовыйНормаПотребленияОбъект.ВариантОпределенияКоличестваЖильцовПриОтсутствииПроживающихИлиЗарегистрированных =
                Перечисления.УПЖКХ_ВариантыРасчетаНормативаПриОтсутствииЖильцов.НеОпределять;
            НовыйНормаПотребленияОбъект.Размер = НормаПотребленияБП77.НормаХВ;

            // Поля миграции
            НовыйНормаПотребленияОбъект.ГП_СозданАвтоматически = Истина;
            НовыйНормаПотребленияОбъект.ГП_ИдентификаторБП77 = НормаПотребленияБП77.Код;

            НовыйНормаПотребленияОбъект.Записать();
            РезультатФункции.СозданныеНормыПотребления.Добавить(НовыйНормаПотребленияОбъект.Ссылка);
        КонецЦикла;

        ЗафиксироватьТранзакцию(); // Записано успешно
    Исключение
        ОтменитьТранзакцию();

        ОбщаяЧастьСообщения = "Ошибка при создании норм потребления услуг.";
        СтруктураОшибки = ГП_МиграцияОбщегоНазначения.ЗаписатьОшибкуВЖурнал(
                ОбщаяЧастьСообщения, ИнформацияОбОшибке(), Ложь, Истина);

        РезультатФункции.Успех = Ложь;
        РезультатФункции.ТекстСообщения = СтрШаблон(
                "%1
                |Информация об ошибке: %2",
                ОбщаяЧастьСообщения,
                СтруктураОшибки.КраткоеПредставлениеОшибки);

        РезультатФункции.СозданныеНормыПотребления.Очистить();
    КонецПопытки;

    Возврат РезультатФункции;
КонецФункции

// Устарела. Требует рефакторинг - объединить с `СоздатьНормыПотребленияХолоднойВодыДляНаселения`
//
// Создает нормы потребления горячей воды по виду тарифа "для населения"
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * СозданныеНормыПотребления - Массив из СправочникСсылка.КВП_НормыПотребленияУслуг
//      * ТекстСообщения - Строка, Неопределено
Функция СоздатьНормыПотребленияГорячейВодыДляНаселения() Экспорт
    РезультатФункции = Новый Структура("Успех, СозданныеНормыПотребления, ТекстСообщения", Истина, Новый Массив);

    ТаблицаДляСозданияНормПотребления = ПолучитьТаблицуДанныхДляСозданияНормПотребленияГВДляНаселения();

    УслугаГорячееВодоснабжение = ГП_МиграцияОбщегоНазначения.ПолучитьУслугуГорячееВодоснабжение().Ссылка;
    ЕдиницыИзмеренияЛитры = Справочники.КлассификаторЕдиницИзмерения.НайтиПоКоду("112");

    НачатьТранзакцию();
    Попытка
        Для Каждого НормаПотребленияБП77 Из ТаблицаДляСозданияНормПотребления Цикл
            НовыйНормаПотребленияОбъект = Справочники.КВП_НормыПотребленияУслуг.СоздатьЭлемент();
            НовыйНормаПотребленияОбъект.Наименование = НормаПотребленияБП77.Наименование;

            НовыйНормаПотребленияОбъект.Владелец = УслугаГорячееВодоснабжение;
            НовыйНормаПотребленияОбъект.НормаНаЛицевойСчет = Истина;
            НовыйНормаПотребленияОбъект.ЕдиницаИзмерения = ЕдиницыИзмеренияЛитры;
            НовыйНормаПотребленияОбъект.ВариантНастройки = Перечисления.КВП_ВариантыНастроекРасчетаНормативовПотребления.Простой;
            НовыйНормаПотребленияОбъект.Основание = Перечисления.КВП_ОснованияНормПотребления.ОдинЧеловек;
            НовыйНормаПотребленияОбъект.ВидЖильцов = Перечисления.УПЖКХ_ВидыЖильцов.Зарегистрированные;
            НовыйНормаПотребленияОбъект.ВариантОпределенияКоличестваЖильцовПриОтсутствииПроживающихИлиЗарегистрированных =
                Перечисления.УПЖКХ_ВариантыРасчетаНормативаПриОтсутствииЖильцов.НеОпределять;
            НовыйНормаПотребленияОбъект.Размер = НормаПотребленияБП77.НормаГВ;

            // Поля миграции
            НовыйНормаПотребленияОбъект.ГП_СозданАвтоматически = Истина;
            НовыйНормаПотребленияОбъект.ГП_ИдентификаторБП77 = НормаПотребленияБП77.Код;

            НовыйНормаПотребленияОбъект.Записать();
            РезультатФункции.СозданныеНормыПотребления.Добавить(НовыйНормаПотребленияОбъект.Ссылка);
        КонецЦикла;

        ЗафиксироватьТранзакцию(); // Записано успешно
    Исключение
        ОтменитьТранзакцию();

        ОбщаяЧастьСообщения = "Ошибка при создании норм потребления услуг.";
        СтруктураОшибки = ГП_МиграцияОбщегоНазначения.ЗаписатьОшибкуВЖурнал(
                ОбщаяЧастьСообщения, ИнформацияОбОшибке(), Ложь, Истина);

        РезультатФункции.Успех = Ложь;
        РезультатФункции.ТекстСообщения = СтрШаблон(
                "%1
                |Информация об ошибке: %2",
                ОбщаяЧастьСообщения,
                СтруктураОшибки.КраткоеПредставлениеОшибки);

        РезультатФункции.СозданныеНормыПотребления.Очистить();
    КонецПопытки;

    Возврат РезультатФункции;
КонецФункции

// Гарант+ Килипенко 15.08.2024 [F00227106] установка норм потребления услуг на л/с ++
//
// Выполняет запись норм потребления услуг для л/с в регистр КВП_НормыПотребленияУслугЛС
// Параметры:
//  ПериодНазначения - Дата - Период назначения (начало месяца)
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * КоличествоЗаписей - Число
//      * ТекстСообщения - Строка, Неопределено
Функция ВыполнитьНазначениеНормПотребленияНаЛицевыеСчета(Знач ПериодНазначения) Экспорт
    РезультатФункции = Новый Структура("Успех, КоличествоЗаписей, ТекстСообщения", Истина, 0);

    // Периодичность - месяц
    ПериодНазначения = НачалоМесяца(ПериодНазначения);

    // Получаем данные для заполнения
    ДанныеДляЗаполнения = ПолучитьТаблицуДанныхДляНазначенияНормПотребленияУслугНаЛС();

    // Запись данных в регистр
    НачатьТранзакцию();
    Попытка
        Для Каждого СтрокаНормаЛС Из ДанныеДляЗаполнения Цикл
            НаборЗаписейНормЛС = СоздатьНаборЗаписейНормПотребленияЛицевыхСчетов(
                    ПериодНазначения, СтрокаНормаЛС.ЛицевойСчет, СтрокаНормаЛС.Услуга);

            НоваяЗаписьНормыЛС = НаборЗаписейНормЛС.Добавить();
            НоваяЗаписьНормыЛС.Период = ПериодНазначения;
            НоваяЗаписьНормыЛС.ЛицевойСчет = СтрокаНормаЛС.ЛицевойСчет;
            НоваяЗаписьНормыЛС.Услуга = СтрокаНормаЛС.Услуга;
            НоваяЗаписьНормыЛС.НормаПотребления = СтрокаНормаЛС.НормаПотребленияУслуги;

            НаборЗаписейНормЛС.Записать(Истина);
            РезультатФункции.КоличествоЗаписей = РезультатФункции.КоличествоЗаписей + 1;
        КонецЦикла;

        ЗафиксироватьТранзакцию(); // Записано успешно
    Исключение
        ОтменитьТранзакцию();

        ОбщаяЧастьСообщения = "Ошибка при назначении норм потребления услуг на л/с.";
        СтруктураОшибки = ГП_МиграцияОбщегоНазначения.ЗаписатьОшибкуВЖурнал(
                ОбщаяЧастьСообщения, ИнформацияОбОшибке(), Ложь, Истина);

        РезультатФункции.Успех = Ложь;
        РезультатФункции.ТекстСообщения = СтрШаблон(
                "%1
                |Информация об ошибке: %2",
                ОбщаяЧастьСообщения,
                СтруктураОшибки.КраткоеПредставлениеОшибки);

        РезультатФункции.КоличествоЗаписей = 0;
    КонецПопытки;

    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 15.08.2024 [F00227106] установка норм потребления услуг на л/с --

#КонецОбласти // ПрограммныйИнтерфейс
// Гарант+ Килипенко 14.08.2024 [F00227047] перенос норм потребления из БП77 --

// Гарант+ Килипенко 14.08.2024 [F00227047] перенос норм потребления из БП77 ++
#Область СлужебныйПрограммныйИнтерфейс

// Выполняет запись исходных данных норм потребления в регистр `ГП_НормыПотребленияБП77` (по данным из БП77)
//  Существующие записи по отбору составного кода будут перезаписаны
// Параметры:
//  ИсходныеДанныеНормПотреблений - Массив из Структура - Данные БП77
//  СохранятьСвязи - Булево - Если Истина, связи с Нормами потребления услуг будут сохранены
// Возвращаемое значение:
//  Структура:
//      * Успех - Булево
//      * КоличествоЗаписанных - Число
//      * КоличествоСохраненныхСвязей - Число
//      * СообщениеОбОшибке - Строка, Неопределено
Функция ЗаписатьДанныеНормПотребленийВРегистр(Знач ИсходныеДанныеНормПотреблений, Знач СохранятьСвязи = Истина) Экспорт
    РезультатФункции = Новый Структура(
            "Успех, КоличествоЗаписанных, КоличествоСохраненныхСвязей, СообщениеОбОшибке", Истина, 0, 0);

    Если ИсходныеДанныеНормПотреблений = Неопределено ИЛИ ИсходныеДанныеНормПотреблений.Количество() = 0 Тогда
        Возврат РезультатФункции; // Нет данных
    КонецЕсли;

    // Поля для предобработки (приведения типов)
    КлючиЧисел = "НормаХВ,НормаГВ,ПроцентХВ,ПроцентГВ";

    // Транзакция записи в регистр
    НачатьТранзакцию();
    Попытка

        Для Каждого НормаПотребленияБП77 Из ИсходныеДанныеНормПотреблений Цикл
            НаборЗаписейНормПотреблений = СоздатьНаборЗаписейНормПотребленияБП77(НормаПотребленияБП77);

            // Данные для сохранения связи
            СвязанныйНормаПотребленияУслуг = Неопределено;
            Если СохранятьСвязи Тогда
                НаборЗаписейНормПотреблений.Прочитать();
                Если НаборЗаписейНормПотреблений.Количество() > 0 Тогда
                    СвязанныйНормаПотребленияУслуг = НаборЗаписейНормПотреблений[0].НормаПотребленияУслуг;
                    СвязанныйНормаПотребленияУслуг = ?(ЗначениеЗаполнено(СвязанныйНормаПотребленияУслуг),
                            СвязанныйНормаПотребленияУслуг, Неопределено);
                    НаборЗаписейНормПотреблений.Очистить();
                КонецЕсли;
            КонецЕсли;
            НоваяЗапись = НаборЗаписейНормПотреблений.Добавить();

            // Заполнение данных
            ЗаполнитьЗначенияСвойств(НоваяЗапись, НормаПотребленияБП77, ,
                СтрШаблон("%1", КлючиЧисел));

            // Заполнение полей с преобразованием типов
            Для Каждого Ключ Из СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(КлючиЧисел, ",", Ложь, Истина) Цикл
                НоваяЗапись[Ключ] = СтроковыеФункцииКлиентСервер.СтрокаВЧисло(НормаПотребленияБП77[Ключ]);
            КонецЦикла;

            НаборЗаписейНормПотреблений.Записать(Истина);
            РезультатФункции.КоличествоЗаписанных = РезультатФункции.КоличествоЗаписанных + 1;
        КонецЦикла;

        ЗафиксироватьТранзакцию(); // Записано успешно
    Исключение
        ОтменитьТранзакцию();

        ОбщаяЧастьСообщения = "Ошибка при загрузке данных норм потребления в регистр ""ГП_НормыПотребленияБП77"".";
        СтруктураОшибки = ГП_МиграцияОбщегоНазначения.ЗаписатьОшибкуВЖурнал(
                ОбщаяЧастьСообщения, ИнформацияОбОшибке(), Ложь, Истина);

        РезультатФункции.Успех = Ложь;
        РезультатФункции.СообщениеОбОшибке = СтрШаблон(
                "%1
                |Информация об ошибке: %2",
                ОбщаяЧастьСообщения,
                СтруктураОшибки.КраткоеПредставлениеОшибки);

        РезультатФункции.КоличествоЗаписанных = 0;
        РезультатФункции.КоличествоСохраненныхСвязей = 0;
    КонецПопытки;

    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  НормаПотребленияБП77 - Структура
//      * Код - Строка - Код ГруппыПотребителей в БП77
//      * Группа - Строка - Наименование группы (папки) ГруппыПотребителей в БП77
//      * Наименование - Строка - Наименование ГруппыПотребителей в БП77
// Возвращаемое значение:
//  - РегистрСведений.ГП_НормыПотребленияБП77.НаборЗаписей
Функция СоздатьНаборЗаписейНормПотребленияБП77(Знач НормаПотребленияБП77) Экспорт
    НаборЗаписей = РегистрыСведений.ГП_НормыПотребленияБП77.СоздатьНаборЗаписей();
    НаборЗаписей.Отбор.Код.Установить(НормаПотребленияБП77.Код);
    НаборЗаписей.Отбор.Группа.Установить(НормаПотребленияБП77.Группа);
    НаборЗаписей.Отбор.Наименование.Установить(НормаПотребленияБП77.Наименование);

    Возврат НаборЗаписей;
КонецФункции

// Устарела. Требует рефакторинг - объединить с `ПолучитьТаблицуДанныхДляСозданияНормПотребленияГВДляНаселения`
//
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Код - Строка
//      * Наименование - Строка
//      * НормаХВ - Число
//      * ЕдИзмНормыХВКод - Строка
//      * ЕдИзмКоличестваХВКод - Строка
//      * ВидТарифаКод - Строка
Функция ПолучитьТаблицуДанныхДляСозданияНормПотребленияХВДляНаселения() Экспорт
    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ГП_НормыПотребленияБП77.Код КАК Код,
        |	ГП_НормыПотребленияБП77.Наименование КАК Наименование,
        |	ГП_НормыПотребленияБП77.НормаХВ КАК НормаХВ,
        |	ГП_НормыПотребленияБП77.ЕдИзмНормыХВКод КАК ЕдИзмНормыХВКод,
        |	ГП_НормыПотребленияБП77.ЕдИзмКоличестваХВКод КАК ЕдИзмКоличестваХВКод,
        |	ГП_НормыПотребленияБП77.ВидТарифаКод КАК ВидТарифаКод
        |ИЗ
        |	РегистрСведений.ГП_НормыПотребленияБП77 КАК ГП_НормыПотребленияБП77
        |ГДЕ
        |	ГП_НормыПотребленияБП77.ВидТарифаКод = ""1"" // Для населения
        |	И ГП_НормыПотребленияБП77.НормаХВ > 0
        |";

    РезультатЗапроса = Запрос.Выполнить();
    РезультатФункции = РезультатЗапроса.Выгрузить();
    Возврат РезультатФункции;
КонецФункции

// Устарела. Требует рефакторинг - объединить с `ПолучитьТаблицуДанныхДляСозданияНормПотребленияХВДляНаселения`
//
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Код - Строка
//      * Наименование - Строка
//      * НормаХВ - Число
//      * ЕдИзмНормыГВКод - Строка
//      * ЕдИзмКоличестваГВКод - Строка
//      * ВидТарифаКод - Строка
Функция ПолучитьТаблицуДанныхДляСозданияНормПотребленияГВДляНаселения() Экспорт
    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ГП_НормыПотребленияБП77.Код КАК Код,
        |	ГП_НормыПотребленияБП77.Наименование КАК Наименование,
        |	ГП_НормыПотребленияБП77.НормаГВ КАК НормаГВ,
        |	ГП_НормыПотребленияБП77.ЕдИзмНормыГВКод КАК ЕдИзмНормыГВКод,
        |	ГП_НормыПотребленияБП77.ЕдИзмКоличестваГВКод КАК ЕдИзмКоличестваГВКод,
        |	ГП_НормыПотребленияБП77.ВидТарифаКод КАК ВидТарифаКод
        |ИЗ
        |	РегистрСведений.ГП_НормыПотребленияБП77 КАК ГП_НормыПотребленияБП77
        |ГДЕ
        |	ГП_НормыПотребленияБП77.ВидТарифаКод = ""1"" // Для населения
        |	И ГП_НормыПотребленияБП77.НормаГВ > 0
        |";

    РезультатЗапроса = Запрос.Выполнить();
    РезультатФункции = РезультатЗапроса.Выгрузить();
    Возврат РезультатФункции;
КонецФункции

// Гарант+ Килипенко 15.08.2024 [F00227106] установка норм потребления услуг на л/с ++
//
// Получает таблицу данных для назначения норм потребления услуг на л/с
// Возвращаемое значение:
//  - ТаблицаЗначений:
//      * ЛицевойСчет - СправочникСсылка.КВП_ЛицевыеСчета
//      * НормаПотребленияУслуги - СправочникСсылка.КВП_НормыПотребленияУслуг
//      * Услуга - СправочникСсылка.КВП_Услуги
Функция ПолучитьТаблицуДанныхДляНазначенияНормПотребленияУслугНаЛС() Экспорт
    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ГП_ЗданияБП77.КонтрагентКод КАК КонтрагентКод,
        |	ГП_ЗданияБП77.ОбъектАбонентаКод КАК ОбъектАбонентаКод,
        |	ГП_ЗданияБП77.ОбъектАбонентаНаименование КАК ОбъектАбонентаНаименование,
        |	ГП_ЗданияБП77.ВидПотребителяКод КАК ВидПотребителяКод,
        |	ГП_ЗданияБП77.ВидПотребителяНаименование КАК ВидПотребителяНаименование
        |ПОМЕСТИТЬ ВТ_Здания
        |ИЗ
        |	РегистрСведений.ГП_ЗданияБП77 КАК ГП_ЗданияБП77
        |ГДЕ
        |	ГП_ЗданияБП77.ЭтоНегативноеВоздействиеЦСВ = ЛОЖЬ
        |	И ГП_ЗданияБП77.ЭтоПлатаЗаХолодноеВодоснабжениеОИ = ЛОЖЬ
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |// Нормы потребления для связи с л/с
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	КВП_НормыПотребленияУслуг.Ссылка КАК НормаПотребленияУслуги,
        |	КВП_НормыПотребленияУслуг.Владелец КАК Услуга,
        |	КВП_НормыПотребленияУслуг.Код КАК КодНормы,
        |	КВП_НормыПотребленияУслуг.Наименование КАК Наименование,
        |	КВП_НормыПотребленияУслуг.НормаНаЛицевойСчет КАК НормаНаЛицевойСчет,
        |	КВП_НормыПотребленияУслуг.ГП_ИдентификаторБП77 КАК ГП_ИдентификаторБП77,
        |	КВП_НормыПотребленияУслуг.ГП_СозданАвтоматически КАК ГП_СозданАвтоматически,
        |	ВТ_Здания.КонтрагентКод КАК КонтрагентКод,
        |	ВТ_Здания.ОбъектАбонентаКод КАК ОбъектАбонентаКод,
        |	ВТ_Здания.ОбъектАбонентаНаименование КАК ОбъектАбонентаНаименование,
        |	ВТ_Здания.ВидПотребителяКод КАК ВидПотребителяКод,
        |	ВТ_Здания.ВидПотребителяНаименование КАК ВидПотребителяНаименование
        |ПОМЕСТИТЬ ВТ_НормыПотребленияЗданийБП77
        |ИЗ
        |	Справочник.КВП_НормыПотребленияУслуг КАК КВП_НормыПотребленияУслуг
        |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Здания КАК ВТ_Здания
        |		ПО (ВТ_Здания.ВидПотребителяКод = КВП_НормыПотребленияУслуг.ГП_ИдентификаторБП77)
        |			И (ВТ_Здания.ВидПотребителяНаименование = КВП_НормыПотребленияУслуг.Наименование)
        |			И (КВП_НормыПотребленияУслуг.ПометкаУдаления = ЛОЖЬ)
        |			И (КВП_НормыПотребленияУслуг.НормаНаЛицевойСчет = ИСТИНА)
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |// Результат Нормы потребления услуг лицевых счетов
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	КВП_ЛицевыеСчета.Ссылка КАК ЛицевойСчет,
        |	ВТ_НормыПотребленияЗданийБП77.НормаПотребленияУслуги КАК НормаПотребленияУслуги,
        |	ВТ_НормыПотребленияЗданийБП77.Услуга КАК Услуга
        |ИЗ
        |	Справочник.КВП_ЛицевыеСчета КАК КВП_ЛицевыеСчета
        |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_НормыПотребленияЗданийБП77 КАК ВТ_НормыПотребленияЗданийБП77
        |		ПО (КВП_ЛицевыеСчета.Идентификатор = ВТ_НормыПотребленияЗданийБП77.ОбъектАбонентаКод + ""_"" + ВТ_НормыПотребленияЗданийБП77.КонтрагентКод)
        |			И (КВП_ЛицевыеСчета.ЭтоГруппа = ЛОЖЬ)
        |			И (КВП_ЛицевыеСчета.ПометкаУдаления = ЛОЖЬ)
        |";

    РезультатЗапроса = Запрос.Выполнить();
    РезультатФункции = РезультатЗапроса.Выгрузить();
    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 15.08.2024 [F00227106] установка норм потребления услуг на л/с --

#КонецОбласти // СлужебныйПрограммныйИнтерфейс
// Гарант+ Килипенко 14.08.2024 [F00227047] перенос норм потребления из БП77 --

// Гарант+ Килипенко 15.08.2024 [F00227106] установка норм потребления услуг на л/с ++
#Область СлужебныеПроцедурыИФункции

// Параметры:
//  Период - Дата
//  ЛицевойСчетСсылка - СправочникСсылка.КВП_ЛицевыеСчета
//  УслугаСсылка - СправочникСсылка.КВП_Услуги
// Возвращаемое значение:
//  - РегистрСведений.КВП_НормыПотребленияУслугЛС.НаборЗаписей
Функция СоздатьНаборЗаписейНормПотребленияЛицевыхСчетов(Знач Период, Знач ЛицевойСчетСсылка, Знач УслугаСсылка)
    НаборЗаписей = РегистрыСведений.КВП_НормыПотребленияУслугЛС.СоздатьНаборЗаписей();
    НаборЗаписей.Отбор.ЛицевойСчет.Установить(ЛицевойСчетСсылка);
    НаборЗаписей.Отбор.Услуга.Установить(УслугаСсылка);

    Возврат НаборЗаписей;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
// Гарант+ Килипенко 15.08.2024 [F00227106] установка норм потребления услуг на л/с --
