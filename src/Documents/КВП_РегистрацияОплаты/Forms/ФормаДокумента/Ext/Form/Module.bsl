﻿// Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления ++ {
#Область ПереопределениеСтандартногоФункционала

&НаСервере
&ИзменениеИКонтроль("ЗаполнитьТабличнуюЧастьЛицевыеСчетаНаСервере")
Процедура ГП_ЗаполнитьТабличнуюЧастьЛицевыеСчетаНаСервере(ТолькоЛицевыеСчетаИмеющиеЗадолженность)

    #Вставка // Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления ++

    ЭтоЗаполнениеПоКонтрагенту = ЗначениеЗаполнено(ЭтотОбъект.Объект.Контрагент) = Истина;
    ЭтоЗаполнениеПоКонтрагенту = ЭтоЗаполнениеПоКонтрагенту И (ЗначениеЗаполнено(ЭтотОбъект.Объект.Дом) = Ложь);

    ДокументаОплатыДляЗаполнения = Неопределено;

    // Получаем документ оплаты
    Если ЭтоЗаполнениеПоКонтрагенту = Истина Тогда
        // Попытка получить документ оплаты из реквизита документа
        ДокументаОплатыДляЗаполнения = ?(ЭтотОбъект.Объект.ДокументыПоступленияДенежныхСредств.Количество() > 0,
                ЭтотОбъект.Объект.ДокументыПоступленияДенежныхСредств[0].Документ, Неопределено);

        Если ЭтотОбъект.Объект.ДокументыПоступленияДенежныхСредств.Количество() > 1 Тогда
            ОбщегоНазначения.СообщитьПользователю("Внимание! при заполнении сумм будет учтен только первый документ оплат");
        КонецЕсли;

        // Попытка получить документ оплаты из ТЧ ЛицевыеСчета
        Если ДокументаОплатыДляЗаполнения <> Неопределено ИЛИ ЗначениеЗаполнено(ДокументаОплатыДляЗаполнения) = Ложь Тогда
            ИсходныеДокументыОплаты = ЭтотОбъект.Объект.ЛицевыеСчета.Выгрузить(, "ДокументОплаты").ВыгрузитьКолонку("ДокументОплаты");
            Если ИсходныеДокументыОплаты.Количество() > 0 Тогда
                ДокументаОплатыДляЗаполнения = ИсходныеДокументыОплаты[0];

                Если ИсходныеДокументыОплаты.Количество() > 1 Тогда
                    ОбщегоНазначения.СообщитьПользователю("Внимание! при заполнении сумм будет учтен только первый документ оплат");
                КонецЕсли;
            КонецЕсли;
        КонецЕсли;

        // Попытка получить документ оплаты из Параметров формы
        Если ДокументаОплатыДляЗаполнения = Неопределено ИЛИ ЗначениеЗаполнено(ДокументаОплатыДляЗаполнения) = Ложь Тогда
            Если ЭтотОбъект.Параметры.Свойство("ГП_ДанныеЗаполнения") = Ложь Тогда
                ОбщегоНазначения.СообщитьПользователю("Не указан документ оплаты");
            Иначе
                ДокументаОплатыДляЗаполнения = ЭтотОбъект.Параметры.ГП_ДанныеЗаполнения.ДокументОплаты;
            КонецЕсли;
        КонецЕсли;
    КонецЕсли;

    #КонецВставки // Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления --
    Объект.ЛицевыеСчета.Очистить();
    Объект.РасшифровкаПлатежа.Очистить();
    Объект.РасшифровкаРассрочки.Очистить();
    Объект.СведенияОДобровольномСтраховании.Очистить();

    // Запрос возвращает список лицевых счетов в зависимости от выбранной пользователем команды "ПодменюЗаполнить":
    // 1. Осуществляется выбор всех счетов, относящихся к выбранному зданию из справочника"КВП_ЛицевыеСчета";
    // 2. Производится отбор действующих счетов среди полученных в п.1, и данные передаются во временную таблицу "втСписокДействующихЛицевыхСчетов";
    // 3. Из действующих лицевых счетов отбираем только те, по которым есть сведения для взаиморасчетов в организации документа, помещаем итоговый список
    //    лицевых счетов во временную таблицу втЛицевыеСчетаИзСведенийДляВзаиморасчетов;
    // 4. Из полученных в п.3 счетов выбираем счета с имеющейся задолженностью и помещаем их во Временную таблицу "втСписокЛицевыхСчетовСЗадолженностью";
    // 5. Соединяем таблицы "втЛицевыеСчетаИзСведенийДляВзаиморасчетов" и "втСписокЛицевыхСчетовСЗадолженностью" левым соединением,
    //    получаем список лицевых счетов, исходя из выбранного пользователем параметра "ТолькоЛицевыеСчетаИмеющиеЗадолженность",
    //    если выбрана команда подменю "ЗаполнитьТаблицуВсемиЛицевымиСчетами" выводятся все действующие лицевые счета из таблицы "втСписокДействующихЛицевыхСчетов",
    //    если выбрана команда подменю "ЗаполнитьЛицевымиСчетамиСЗадолженностью" выводятся все действующие лицевые счета из таблицы "втСписокЛицевыхСчетовСЗадолженностью".

    Запрос = Новый Запрос;
    Запрос.УстановитьПараметр("Период",                  Новый Граница(Объект.Дата, ВидГраницы.Исключая));
    Запрос.УстановитьПараметр("Организация",             Объект.Организация);
    #Удаление // Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления
    Запрос.УстановитьПараметр("Здание",                  Объект.Дом);
    #КонецУдаления
    #Вставка // Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления ++

    Если ЭтоЗаполнениеПоКонтрагенту = Истина Тогда
        Запрос.УстановитьПараметр("Контрагент", ЭтотОбъект.Объект.Контрагент);
    Иначе
        Запрос.УстановитьПараметр("Здание", ЭтотОбъект.Объект.Дом);
    КонецЕсли;

    #КонецВставки // Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления --
    Запрос.УстановитьПараметр("НачалоПредыдущегоМесяца", НачалоМесяца(ДобавитьМесяц(Объект.Дата, - 1)));
    Запрос.УстановитьПараметр("КонецПредыдущегоМесяца",  КонецМесяца(ДобавитьМесяц(Объект.Дата, - 1)));
    Запрос.УстановитьПараметр("СледующийМесяц",          КонецМесяца(ДобавитьМесяц(Объект.Дата, 1)));
    Запрос.УстановитьПараметр("УслугаСтрахования",       УслугаДобровольногоСтрахования);

    Запрос.УстановитьПараметр("ТолькоЛицевыеСчетаИмеющиеЗадолженность", ТолькоЛицевыеСчетаИмеющиеЗадолженность);

    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	КВП_ЛицевыеСчета.Ссылка КАК ЛицевойСчет
        |ПОМЕСТИТЬ втСписокЛицевыхСчетов
        |ИЗ
        |	Справочник.КВП_ЛицевыеСчета КАК КВП_ЛицевыеСчета
        |ГДЕ
        |	КВП_ЛицевыеСчета.Адрес.Владелец В ИЕРАРХИИ(&Здание)
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ЛицевыеСчета.ЛицевойСчет
        |ПОМЕСТИТЬ втСписокДействующихЛицевыхСчетов
        |ИЗ
        |	РегистрСведений.КВП_ЛицевыеСчета.СрезПоследних(
        |			&Период,
        |			ЛицевойСчет В
        |				(ВЫБРАТЬ
        |					втСписокЛицевыхСчетов.ЛицевойСчет
        |				ИЗ
        |					втСписокЛицевыхСчетов КАК втСписокЛицевыхСчетов)) КАК ЛицевыеСчета
        |ГДЕ
        |	ЛицевыеСчета.Действует
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	УПЖКХ_СведенияДляВзаиморасчетовПоЛССрезПоследних.ЛицевойСчет,
        |	УПЖКХ_СведенияДляВзаиморасчетовПоЛССрезПоследних.ЛицевойСчет.Наименование
        |ПОМЕСТИТЬ втЛицевыеСчетаИзСведенийДляВзаиморасчетов
        |ИЗ
        |	РегистрСведений.УПЖКХ_СведенияДляВзаиморасчетовПоЛС.СрезПоследних(
        |			&Период,
        |			ЛицевойСчет В
        |					(ВЫБРАТЬ
        |						втСписокДействующихЛицевыхСчетов.ЛицевойСчет
        |					ИЗ
        |						втСписокДействующихЛицевыхСчетов КАК втСписокДействующихЛицевыхСчетов)
        |				И Организация = &Организация) КАК УПЖКХ_СведенияДляВзаиморасчетовПоЛССрезПоследних
    #Вставка // Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления ++
        |ГДЕ
        |   ИСТИНА
        |   И &ГП_УсловиеСведенийДляВзаиморасчетовПоЛС
    #КонецВставки // Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления --
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	УПЖКХ_НачисленияПоДобровольномуСтрахованиюОбороты.ЛицевойСчет
        |ПОМЕСТИТЬ втСписокЛицевыхСчетовСоСтрахованием
        |ИЗ
        |	РегистрНакопления.УПЖКХ_НачисленияПоДобровольномуСтрахованию.Обороты(
        |			&НачалоПредыдущегоМесяца,
        |			&КонецПредыдущегоМесяца,
        |			,
        |			Организация = &Организация
        |				И ЛицевойСчет В
        |					(ВЫБРАТЬ
        |						втСписокДействующихЛицевыхСчетов.ЛицевойСчет
        |					ИЗ
        |						втСписокДействующихЛицевыхСчетов КАК втСписокДействующихЛицевыхСчетов)
        |				И Услуга = &УслугаСтрахования
        |				И КОНЕЦПЕРИОДА(МесяцНачисления, МЕСЯЦ) = &СледующийМесяц) КАК УПЖКХ_НачисленияПоДобровольномуСтрахованиюОбороты
        |ГДЕ
        |	УПЖКХ_НачисленияПоДобровольномуСтрахованиюОбороты.СуммаНачисленияОборот > 0
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	КВП_ВзаиморасчетыПоЛицевымСчетамОстатки.ЛицевойСчет,
        |	КВП_ВзаиморасчетыПоЛицевымСчетамОстатки.СуммаНачисленияОстаток
        |ПОМЕСТИТЬ втСписокЛицевыхСчетовСЗадолженностью
        |ИЗ
        |	РегистрНакопления.КВП_ВзаиморасчетыПоЛицевымСчетам.Остатки(
        |			&Период,
        |			Организация = &Организация
        |				И ЛицевойСчет В
        |					(ВЫБРАТЬ
        |						втЛицевыеСчетаИзСведенийДляВзаиморасчетов.ЛицевойСчет
        |					ИЗ
        |						втЛицевыеСчетаИзСведенийДляВзаиморасчетов КАК втЛицевыеСчетаИзСведенийДляВзаиморасчетов)
        |				И &УсловиеНаУслуги) КАК КВП_ВзаиморасчетыПоЛицевымСчетамОстатки
        |ГДЕ
        |	КВП_ВзаиморасчетыПоЛицевымСчетамОстатки.СуммаНачисленияОстаток > 0
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ
        |	ЕСТЬNULL(втСписокЛицевыхСчетовСЗадолженностью.ЛицевойСчет, втСписокЛицевыхСчетовСоСтрахованием.ЛицевойСчет) КАК ЛицевойСчет
        |ПОМЕСТИТЬ втСписокЛицевыхСчетовСДолгамиИНачислениями
        |ИЗ
        |	втСписокЛицевыхСчетовСоСтрахованием КАК втСписокЛицевыхСчетовСоСтрахованием
        |		ПОЛНОЕ СОЕДИНЕНИЕ втСписокЛицевыхСчетовСЗадолженностью КАК втСписокЛицевыхСчетовСЗадолженностью
        |		ПО втСписокЛицевыхСчетовСоСтрахованием.ЛицевойСчет = втСписокЛицевыхСчетовСЗадолженностью.ЛицевойСчет
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ
        |	втЛицевыеСчетаИзСведенийДляВзаиморасчетов.ЛицевойСчет КАК Объект
        |ИЗ
        |	втЛицевыеСчетаИзСведенийДляВзаиморасчетов КАК втЛицевыеСчетаИзСведенийДляВзаиморасчетов
        |		ЛЕВОЕ СОЕДИНЕНИЕ втСписокЛицевыхСчетовСДолгамиИНачислениями КАК втСписокЛицевыхСчетовСДолгамиИНачислениями
        |		ПО втЛицевыеСчетаИзСведенийДляВзаиморасчетов.ЛицевойСчет = втСписокЛицевыхСчетовСДолгамиИНачислениями.ЛицевойСчет
        |ГДЕ
        |	(НЕ &ТолькоЛицевыеСчетаИмеющиеЗадолженность
        |			ИЛИ ВЫБОР
        |				КОГДА втСписокЛицевыхСчетовСДолгамиИНачислениями.ЛицевойСчет ЕСТЬ NULL
        |					ТОГДА ЛОЖЬ
        |				ИНАЧЕ ИСТИНА
        |			КОНЕЦ)
        |
        |УПОРЯДОЧИТЬ ПО
        |	втЛицевыеСчетаИзСведенийДляВзаиморасчетов.ЛицевойСчетНаименование";

    // Необходимо учесть возможность раздельного учета услуг кап. ремонта.
    УсловиеНаУслуги = "ИСТИНА";
    Если мСтруктураНастроекКапРемонта.ВедетсяРаздельныйУчет Тогда
        Если Объект.ВариантРаспределенияОплатКапРемонт = Перечисления.УПЖКХ_ВариантыРаспределенияОплатыПриРаздельномУчетеКР.УслугиНеКапРемонт Тогда
            УсловиеНаУслуги = "НЕ Услуга В (&СписокУслугКапРемонта)";
        ИначеЕсли Объект.ВариантРаспределенияОплатКапРемонт = Перечисления.УПЖКХ_ВариантыРаспределенияОплатыПриРаздельномУчетеКР.УслугиКапРемонт Тогда
            УсловиеНаУслуги = "Услуга В (&СписокУслугКапРемонта)"
            КонецЕсли;
    КонецЕсли;

    Запрос.Текст = СтрЗаменить(Запрос.Текст, "&УсловиеНаУслуги", УсловиеНаУслуги);
    Запрос.УстановитьПараметр("СписокУслугКапРемонта", мСтруктураНастроекКапРемонта.СписокУслуг);

    #Вставка // Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления ++

    ГП_ДанныеЗамены = Новый Структура;
    ГП_ДанныеЗамены.Вставить("ИсходныйТекстУсловияЗамены", "&ГП_УсловиеСведенийДляВзаиморасчетовПоЛС");
    ГП_ДанныеЗамены.Вставить("ТекстЗамены", "ИСТИНА");

    Если ЭтоЗаполнениеПоКонтрагенту = Истина Тогда
        // Добавляем условие по Контрагенту
        ГП_ДанныеЗамены.Вставить("ТекстЗамены", "УПЖКХ_СведенияДляВзаиморасчетовПоЛССрезПоследних.Контрагент = &Контрагент");
        Запрос.Текст = СтрЗаменить(Запрос.Текст, ГП_ДанныеЗамены.ИсходныйТекстУсловияЗамены, ГП_ДанныеЗамены.ТекстЗамены);
        Запрос.УстановитьПараметр("Контрагент", ЭтотОбъект.Объект.Контрагент);

        // Исключаем фильтр по зданиям
        ГП_ДанныеЗамены.ИсходныйТекстУсловияЗамены = "КВП_ЛицевыеСчета.Адрес.Владелец В ИЕРАРХИИ(&Здание)";
        ГП_ДанныеЗамены.ТекстЗамены = "ИСТИНА";
        Запрос.Текст = СтрЗаменить(Запрос.Текст, ГП_ДанныеЗамены.ИсходныйТекстУсловияЗамены, ГП_ДанныеЗамены.ТекстЗамены);

        // Гарант+ Килипенко 21.03.2025 [F00236141] Приоритетное погашение долга закрытых л/с ++ {
        // Учет начислений по закрытым л/с
        РаспределятьТолькоПоДействующимЛицевымСчетам = ГП_РаспределятьТолькоПоДействующимЛицевымСчетам(ЭтотОбъект);
        Если РаспределятьТолькоПоДействующимЛицевымСчетам = Ложь Тогда
            ИсходныйТекстЗапросаДляКонтроля = Запрос.Текст;
            Запрос.Текст = СтрЗаменитьПоРегулярномуВыражению(
                Запрос.Текст, "(\s*(?:И\s+)?)ЛицевыеСчета\.Действует\s*(?:\=\s*ИСТИНА)?", "$1ИСТИНА");

            #Область Отладка
            ГП_ДиагностикаКлиентСервер.Утверждение(Запрос.Текст <> ИсходныйТекстЗапросаДляКонтроля,
                "Не удалось изменить текст запроса для учета начислений по закрытым л/с");
            #КонецОбласти // Отладка
        КонецЕсли;
        // Гарант+ Килипенко 21.03.2025 [F00236141] Приоритетное погашение долга закрытых л/с -- }

    Иначе
        // Заменяем &ГП_УсловиеСведенийДляВзаиморасчетовПоЛС на ИСТИНА
        Запрос.Текст = СтрЗаменить(Запрос.Текст, ГП_ДанныеЗамены.ИсходныйТекстУсловияЗамены, ГП_ДанныеЗамены.ТекстЗамены);
    КонецЕсли;

    #КонецВставки // Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления --
    Объект.ЛицевыеСчета.Загрузить(Запрос.Выполнить().Выгрузить());

    #Вставка // Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления ++

    Если ЭтоЗаполнениеПоКонтрагенту Тогда

        СуммаРаспределенияПоЛС = 0;

        Если ЭтотОбъект.Параметры.Свойство("ГП_ДанныеЗаполнения") = Истина Тогда
            СуммаРаспределенияПоЛС = ЭтотОбъект.Параметры.СуммаДокументаОплаты;
        КонецЕсли;

        Если СуммаРаспределенияПоЛС = 0
            И ДокументаОплатыДляЗаполнения <> Неопределено
            И ЗначениеЗаполнено(ДокументаОплатыДляЗаполнения) = Истина Тогда

            СуммаРаспределенияПоЛС = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокументаОплатыДляЗаполнения, "СуммаДокумента");
        КонецЕсли;

        СуммаРаспределенияПоЛС = ?(СуммаРаспределенияПоЛС = Неопределено, 0, СуммаРаспределенияПоЛС);

        СписокЛицевыхСчетов = ЭтотОбъект.Объект.ЛицевыеСчета.Выгрузить(, "Объект").ВыгрузитьКолонку("Объект");
        Если ДокументаОплатыДляЗаполнения <> Неопределено И СписокЛицевыхСчетов <> Неопределено И СписокЛицевыхСчетов.Количество() > 0 Тогда
            ДоговорКонтрагентаДляФильтрацииЛС = ГП_РегистрацияОплатыСлужебный.ПолучитьДоговорКонтрагентаДокументаОплаты(
                    ДокументаОплатыДляЗаполнения);

            Если ДоговорКонтрагентаДляФильтрацииЛС = Неопределено ИЛИ ЗначениеЗаполнено(ДоговорКонтрагентаДляФильтрацииЛС) = Ложь Тогда
                ОбщегоНазначения.СообщитьПользователю("ВНИМАНИЕ!!! Не удалось определить договор контрагента документа оплаты"
                    + Символы.ПС + "Заполнение выполняется по всем лицевым счетам контрагента (буз учета договора)");
            Иначе
                СписокЛицевыхСчетов = ГП_РаботаСЛицевымиСчетами.ПолучитьОтфильтрованныйСписокЛицевыхСчетовПоДоговорам(СписокЛицевыхСчетов,
                        ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ДоговорКонтрагентаДляФильтрацииЛС), ЭтотОбъект.Объект.Дата);
            КонецЕсли;
        КонецЕсли;

        ГП_ЗаполнитьТаблицуЛицевыхСчетовПоКонтрагентуНаСервере(СуммаРаспределенияПоЛС, ДокументаОплатыДляЗаполнения, СписокЛицевыхСчетов);
    КонецЕсли;

    #КонецВставки // Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления --
    // Вызываем процедуру "ЗаполнитьДопДанныеВТаблице" для заполнения следующих реквизитов:
    // "Помещение", "Владелец", "ФлагРедактированияНастроек".
    ЗаполнитьДопДанныеВТаблице();
    ОбновитьСтатусыЧековВТабличнойЧастиСервере();

КонецПроцедуры

#КонецОбласти // ПереопределениеСтандартногоФункционала
// Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления -- }

// Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления ++ {
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ГП_ПриЧтенииНаСервереПосле(ТекущийОбъект)
    // Создание дополнительных элементов формы
    ГП_СоздатьДополнительныеЭлементыНаСервере();

    // Обновление оформления поля формы
    ГП_ОбновитьОформлениеПоляОплатаОтПокупателяФизЛицаНаСервере();
КонецПроцедуры

&НаСервере
Процедура ГП_ПриСозданииНаСервереПеред(Отказ, СтандартнаяОбработка)
    // Создание дополнительных элементов формы
    ГП_СоздатьДополнительныеЭлементыНаСервере();

    // Заполнение документа распределения по данным документа оплаты
    Если ЗначениеЗаполнено(ЭтотОбъект.Объект.Ссылка) = Ложь И ЭтотОбъект.Параметры.Свойство("ГП_ДанныеЗаполнения") = Истина Тогда
        ДокументОбъект = ЭтотОбъект.РеквизитФормыВЗначение("Объект");

        ДокументОбъект.Заполнить(ЭтотОбъект.Параметры.ГП_ДанныеЗаполнения);
        ДокументОбъект.Дата = ЭтотОбъект.Параметры.ГП_ДанныеЗаполнения.Дата;
        ДокументОбъект.Контрагент = ЭтотОбъект.Параметры.ГП_ДанныеЗаполнения.Контрагент;

        ДокументОбъект.ДокументыПоступленияДенежныхСредств.Очистить();
        НоваяСтрокаДокументов = ДокументОбъект.ДокументыПоступленияДенежныхСредств.Добавить();
        НоваяСтрокаДокументов.Документ = ЭтотОбъект.Параметры.ГП_ДанныеЗаполнения.ДокументОплаты;

        ЭтотОбъект.ЗначениеВРеквизитФормы(ДокументОбъект, "Объект");

        ГП_ЗаполнитьТаблицуЛицевыхСчетовПоКонтрагентуНаСервере(
            ЭтотОбъект.Параметры.ГП_ДанныеЗаполнения.СуммаДокументаОплаты,
            ЭтотОбъект.Параметры.ГП_ДанныеЗаполнения.ДокументОплаты);
    КонецЕсли;

    ГП_НастроитьВидимостьЭлементовФормыНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ГП_ОплатаОтПокупателяФизЛицаПриИзменении(Элемент)
    ГП_ОбновитьОформлениеПоляОплатаОтПокупателяФизЛицаНаСервере();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы
// Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления -- }

// Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления ++ {
#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ГП_ЗаполнитьТаблицуЛицевыхСчетовПоКонтрагентуНаСервере(
        Знач СуммаРаспределенияПоЛС, Знач ДокументОплаты, Знач СписокЛицевыхСчетов = Неопределено, Знач ТолькоПоДоговорамДокументаОплаты = Истина)

    // Получение договоров контрагента документа оплаты
    МассивДоговоровКонтрагентов = Новый Массив;
    Если ТолькоПоДоговорамДокументаОплаты = Истина Тогда
        ДоговорКонтрагентаДокументаОплаты = ГП_РегистрацияОплатыСлужебный.ПолучитьДоговорКонтрагентаДокументаОплаты(ДокументОплаты);
        Если ДоговорКонтрагентаДокументаОплаты <> Неопределено И ЗначениеЗаполнено(ДоговорКонтрагентаДокументаОплаты) Тогда
            МассивДоговоровКонтрагентов.Добавить(ДоговорКонтрагентаДокументаОплаты);
        КонецЕсли;

        ДоговорКонтрагентаДокументаОплаты = Неопределено;
    КонецЕсли;

    МассивДоговоровКонтрагентов = ?(МассивДоговоровКонтрагентов.Количество() = 0, Неопределено, МассивДоговоровКонтрагентов);

    // Получение таблицы л/с контрагента
    ТолькоДействующиеЛицевыеСчета = ГП_РаспределятьТолькоПоДействующимЛицевымСчетам(ЭтотОбъект);
    СписокЛицевыхСчетов = ?(СписокЛицевыхСчетов <> Неопределено, СписокЛицевыхСчетов,
            ГП_РаботаСЛицевымиСчетами.ПолучитьЛицевыеСчетаКонтрагента(
                ЭтотОбъект.Объект.Контрагент,
                ЭтотОбъект.Объект.Организация,
                ЭтотОбъект.Объект.Дата,
                ТолькоДействующиеЛицевыеСчета,
                МассивДоговоровКонтрагентов));

    // Список закрытых л/с
    СписокЗакрытыхЛицевыхСчетов = Новый Массив;
    Если ТолькоДействующиеЛицевыеСчета = Ложь Тогда
        СписокЗакрытыхЛицевыхСчетов =
            ГП_РаботаСЛицевымиСчетами.ПолучитьЗакрытыеЛицевыеСчетаИзСписка(СписокЛицевыхСчетов, ЭтотОбъект.Объект.Дата);
    КонецЕсли;

    // Очистка основного списка от закрытых л/с
    ГП_ВспомогательныеФункцииКлиентСервер.УдалитьЭлементыМассива(СписокЛицевыхСчетов, СписокЗакрытыхЛицевыхСчетов);

    // Получение данные взаиморасчетов по л/с
    ТаблицаНачисленийНаЛС = ГП_ПолучитьНачисленияДляСпискаЛицевыхСчетовНаСервере(
            СписокЛицевыхСчетов, ЭтотОбъект.Объект.Организация, Новый Граница(ЭтотОбъект.Объект.Дата, ВидГраницы.Исключая));
    ТаблицаНачисленийНаЗакрытыеЛС = ГП_ПолучитьНачисленияДляСпискаЛицевыхСчетовНаСервере(
            СписокЗакрытыхЛицевыхСчетов, ЭтотОбъект.Объект.Организация, Новый Граница(ЭтотОбъект.Объект.Дата, ВидГраницы.Исключая));
    СуммаРаспределенияНаЗакрытыеЛС = 0;
    Если ТаблицаНачисленийНаЗакрытыеЛС.Количество() > 0 Тогда
        СуммаРаспределенияНаЗакрытыеЛС = Макс(ТаблицаНачисленийНаЗакрытыеЛС.Итог("СуммаНачисленияОстаток"), 0);
        СуммаРаспределенияНаЗакрытыеЛС = Макс(Мин(СуммаРаспределенияПоЛС, СуммаРаспределенияНаЗакрытыеЛС), 0);
        СуммаРаспределенияПоЛС = СуммаРаспределенияПоЛС - СуммаРаспределенияНаЗакрытыеЛС;
        СуммаРаспределенияПоЛС = Макс(СуммаРаспределенияПоЛС, 0);
    КонецЕсли;

    // Формирования таблицы данных распределения оплаты по л/с
    ДанныеЗаполнения = ГП_СформироватьТаблицуОплатДляСпискаЛСНаСервере(
            ТаблицаНачисленийНаЛС, СуммаРаспределенияПоЛС, ДокументОплаты, ЭтотОбъект.Объект.Контрагент);
    // Дополнение таблицы распределения данными по закрытым л/с
    Если СуммаРаспределенияНаЗакрытыеЛС > 0 Тогда
        ДанныеЗаполненияЗакрытыхЛС = ГП_СформироватьТаблицуОплатДляСпискаЛСНаСервере(
                ТаблицаНачисленийНаЗакрытыеЛС, СуммаРаспределенияНаЗакрытыеЛС, ДокументОплаты, ЭтотОбъект.Объект.Контрагент);

        // Добавление временной колонки для сортировки
        ВременнаяКолонкаСортировки = ДанныеЗаполнения.Колонки.Добавить(
                "ПриоритетСтрокиДляСортировки", ОбщегоНазначения.ОписаниеТипаЧисло(10, 0));

        // Закрепление приоритетов строк для сортировки
        ПриоритетТекущейСтроки = ДанныеЗаполненияЗакрытыхЛС.Количество();
        Для Каждого ТекущаяСтрокаДанных Из ДанныеЗаполнения Цикл
            ТекущаяСтрокаДанных[ВременнаяКолонкаСортировки.Имя] = ПриоритетТекущейСтроки;
            ПриоритетТекущейСтроки = ПриоритетТекущейСтроки + 1;
        КонецЦикла;

        // Дополнение таблицы строками закрытых л/с
        ПриоритетТекущейСтроки = 0;
        Для Каждого ТекущаяСтрокаДанных Из ДанныеЗаполненияЗакрытыхЛС Цикл
            НоваяСтрокаДанных = ДанныеЗаполнения.Добавить();
            ЗаполнитьЗначенияСвойств(НоваяСтрокаДанных, ТекущаяСтрокаДанных);
            НоваяСтрокаДанных[ВременнаяКолонкаСортировки.Имя] = ПриоритетТекущейСтроки;
            ПриоритетТекущейСтроки = ПриоритетТекущейСтроки + 1;
        КонецЦикла;

        ДанныеЗаполнения.Сортировать(ВременнаяКолонкаСортировки.Имя);

        // Удаление временной колонки для сортировки
        ДанныеЗаполнения.Колонки.Удалить(ВременнаяКолонкаСортировки);
    КонецЕсли;

    // Заполнение ТЧ ЛицевыеСчета:

    // Очистка табличных частей документа
    ГП_ОчиститьЗаполненныеДанныеОплатНаСервере();

    // Исключено из ТЗ (установка списка услуг в настройках распределения)
    //
    // // Формирование настроек распределения
    // СписокУслугДляРаспределения = ГП_РегистрацияОплатыСлужебный.ПолучитьСписокУслугПоУмолчаниюДляРаспределения();
    // НастройкиРаспределенияПоУмолчанию =
    //     ГП_РегистрацияОплатыСлужебный.НовыйПредопределенныеНастройкиРаспределенияПоСпискуУслуг(СписокУслугДляРаспределения);

    // По умолчанию - Настройка распределения: "Автоматически"
    НастройкиРаспределенияПоУмолчанию = Новый Структура;
    НастройкиРаспределенияПоУмолчанию.Вставить("РаспределятьПоУказаннымУслугам", Ложь);
    НастройкиРаспределенияПоУмолчанию.Вставить("ФлагРедактирования", Ложь);
    НастройкиРаспределенияПоУмолчанию.Вставить("ФлагРедактированияНастроек", 1);
    НастройкиРаспределенияПоУмолчанию.Вставить("ВариантРаспределения", "");

    Для Каждого СтрокаДанных Из ДанныеЗаполнения Цикл
        Если СтрокаДанных.СуммаПоГрафику = 0 И СтрокаДанных.Сумма = 0 Тогда
            Продолжить;
        КонецЕсли;

        НоваяСтрокаЛС = ЭтотОбъект.Объект.ЛицевыеСчета.Добавить();
        ЗаполнитьЗначенияСвойств(НоваяСтрокаЛС, СтрокаДанных);
        НоваяСтрокаЛС.ИдентификаторСтрокиЛС = Строка(Новый УникальныйИдентификатор);

        // По умолчанию - Настройка распределения: "Автоматически"
        ЗаполнитьЗначенияСвойств(НоваяСтрокаЛС, НастройкиРаспределенияПоУмолчанию);

        // Исключено из ТЗ (установка списка услуг в настройках распределения)
        //
        // // Настройки распределения ПоУслугам с фиксированным списком услуг
        // ЗаполнитьЗначенияСвойств(НоваяСтрокаЛС, НастройкиРаспределенияПоУмолчанию);
    КонецЦикла;

    // Заполнение ТЧ НастройкиОплаты (если необходимо)
    Если НастройкиРаспределенияПоУмолчанию <> Неопределено И НастройкиРаспределенияПоУмолчанию.Свойство("НастройкиОплатыОбъекта") Тогда
        Для Каждого СтрокаЛС Из ЭтотОбъект.Объект.ЛицевыеСчета Цикл
            // Удаление ранее созданных настроек по текущему л/с
            НайденныеСтроки = ЭтотОбъект.Объект.НастройкиОплаты.НайтиСтроки(
                    Новый Структура("ИдентификаторСтрокиЛС", СтрокаЛС.ИдентификаторСтрокиЛС));
            Для Каждого СтрокаДляУдаления Из НайденныеСтроки Цикл
                ЭтотОбъект.Объект.НастройкиОплаты.Удалить(СтрокаДляУдаления);
            КонецЦикла;

            // Заполнение таблицы
            Для Каждого СтрокаКоллекции Из НастройкиРаспределенияПоУмолчанию.НастройкиОплатыОбъекта Цикл
                НоваяСтрокаНастройкиОплаты = ЭтотОбъект.Объект.НастройкиОплаты.Добавить();

                ЗаполнитьЗначенияСвойств(НоваяСтрокаНастройкиОплаты, СтрокаКоллекции);
                НоваяСтрокаНастройкиОплаты.Объект = СтрокаЛС.Объект;
                НоваяСтрокаНастройкиОплаты.ИдентификаторСтрокиЛС = СтрокаЛС.ИдентификаторСтрокиЛС;
            КонецЦикла;
        КонецЦикла;
    КонецЕсли;

    ЗаполнитьДопДанныеВТаблице();
    ОбновитьСтатусыЧековВТабличнойЧастиСервере();
КонецПроцедуры

// Устарела. Переход на `ГП_РегистрацияОплатыСлужебный.СформироватьТаблицуОплатДляСпискаЛС`
//
// Параметры:
//  ТаблицаНачисленийНаЛС - ТаблицаЗначений
//  СуммаРаспределения - Число
//  ДокументОплаты - ДокументСсылка
//  Контрагент - СправочникСсылка.Контрагенты
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Объект - СправочникСсылка.КВП_ЛицевыеСчета
//      * ДокументОплаты - ДокументСсылка
//      * Сумма - Число
//      * Помещение - СправочникСсылка.УПЖКХ_Помещения
//      * Здание - СправочникСсылка.КВП_Здания
//      * Владелец - СправочникСсылка.Контрагенты
&НаСервере
Функция ГП_СформироватьТаблицуОплатДляСпискаЛСНаСервере(
        Знач ТаблицаНачисленийНаЛС, Знач СуммаРаспределения, Знач ДокументОплаты, Знач Контрагент)

    Возврат ГП_РегистрацияОплатыСлужебный.СформироватьТаблицуОплатДляСпискаЛС(
        ТаблицаНачисленийНаЛС, СуммаРаспределения, ДокументОплаты, Контрагент);
КонецФункции

&НаСервере
Функция ГП_ВыполнитьРаспределениеОплатыНаСервере(Знач ДанныеДляРаспределения, Знач ПараметрыРаспределения)
    Возврат ГП_РегистрацияОплатыСлужебный.СформироватьТаблицуРаспределенияОплаты(
        ПараметрыРаспределения.СуммаРаспределения,
        ПараметрыРаспределения.ОбщаяСуммаНачислений,
        ДанныеДляРаспределения,
        ПараметрыРаспределения.ДокументОплаты,
        ПараметрыРаспределения.Контрагент,
        ?(ПараметрыРаспределения.Свойство("РаспределятьРавномерно"), ПараметрыРаспределения.РаспределятьРавномерно, Ложь));
КонецФункции

&НаСервереБезКонтекста
Функция ГП_РассчитатьКоэффициентРаспределенияНаСервере(
        Знач СуммаНачисления, Знач СуммаРаспределения, Знач КоличествоСтрокРаспределения = Неопределено)

    Возврат ГП_РегистрацияОплатыСлужебный.РассчитатьКоэффициентРаспределения(
        СуммаНачисления, СуммаРаспределения, КоличествоСтрокРаспределения);
КонецФункции

&НаСервереБезКонтекста
Функция ГП_ПодготовитьСтруктуруДанныхДляРаспределенияОплатыНаСервере(Знач ТаблицаНачисленийНаЛС)
    Возврат ГП_РегистрацияОплатыСлужебный.ПодготовитьСтруктуруДанныхДляРаспределенияОплаты(ТаблицаНачисленийНаЛС);
КонецФункции

// Параметры:
//  СписокЛицевыхСчетов - Массив, СписокЗначений из СправочникСсылка.КВП_ЛицевыеСчета
//  ОрганизацияСсылка - СправочникСсылка.Организации, Неопределено
//  Период - Дата, Неопределено
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * ЛицевойСчет - СправочникСсылка.КВП_ЛицевыеСчета
//      * СуммаНачисленияОстаток - Число
&НаСервереБезКонтекста
Функция ГП_ПолучитьНачисленияДляСпискаЛицевыхСчетовНаСервере(
        Знач СписокЛицевыхСчетов, Знач ОрганизацияСсылка, Знач Период = Неопределено)

    ТаблицаНачисленийНаЛС = ГП_РегистрацияОплатыСлужебный.ПолучитьНачисленияДляСпискаЛицевыхСчетов(
            СписокЛицевыхСчетов, ОрганизацияСсылка, Период);

    Если ТаблицаНачисленийНаЛС.Количество() = 0 Тогда
        // Если нет остатков по взаиморасчетам но есть л/с
        Для Каждого ТекущийЛС Из СписокЛицевыхСчетов Цикл
            НоваяСтрокаДанных = ТаблицаНачисленийНаЛС.Добавить();
            НоваяСтрокаДанных.ЛицевойСчет = ТекущийЛС;
            НоваяСтрокаДанных.СуммаНачисленияОстаток = 0;
        КонецЦикла;
    КонецЕсли;

    Возврат ТаблицаНачисленийНаЛС;
КонецФункции

&НаСервере
Процедура ГП_ОчиститьЗаполненныеДанныеОплатНаСервере()
    ЭтотОбъект.Объект.ЛицевыеСчета.Очистить();
    ЭтотОбъект.Объект.РасшифровкаПлатежа.Очистить();
    ЭтотОбъект.Объект.РасшифровкаРассрочки.Очистить();
    ЭтотОбъект.Объект.СведенияОДобровольномСтраховании.Очистить();
    ЭтотОбъект.Объект.НастройкиОплаты.Очистить();
КонецПроцедуры

// Гарант+ Килипенко 21.03.2025 [F00236141] Приоритетное погашение долга закрытых л/с ++ {
//
// Возвращаемое значение:
//  - Структура
//      * ТолькоДействующиеЛицевыеСчета - Булево
&НаКлиентеНаСервереБезКонтекста
Функция ГП_НовыйСтруктураДополнительныхПараметров()
    Возврат ГП_РегистрацияОплатыСлужебныйКлиентСервер.НовыйСтруктураДополнительныхПараметровРаспределения();
КонецФункции // Гарант+ Килипенко 21.03.2025 [F00236141] Приоритетное погашение долга закрытых л/с -- }

// Возвращаемое значение:
//  - Булево
&НаКлиентеНаСервереБезКонтекста
Функция ГП_РаспределятьТолькоПоДействующимЛицевымСчетам(Знач Форма)
    Возврат Форма.ГП_ДополнительныеПараметрыЗаполнения.ТолькоДействующиеЛицевыеСчета;
КонецФункции

#Область НастройкиФормы

// Возвращаемое значение:
//  - Структура
&НаСервере
Функция ГП_СоздатьПолеКонтрагентНаСервере()
    РезультатФункции = Новый Структура("Элемент");

    // Создание элемента формы
    ИмяСоздаваемогоЭлемента = "ГП_Контрагент";

    // Проверка наличия поля формы
    Если ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(ЭтотОбъект.Элементы, ИмяСоздаваемогоЭлемента) Тогда
        РезультатФункции.Элемент = ЭтотОбъект.Элементы[ИмяСоздаваемогоЭлемента];

        Возврат РезультатФункции; // Элемент уже существует
    КонецЕсли;

    ПараметрыЭлемента = Новый Структура("Заголовок, ПутьКДанным, Видимость");
    ПараметрыЭлемента.Заголовок = "Контрагент";
    ПараметрыЭлемента.ПутьКДанным = "Объект.Контрагент";
    ПараметрыЭлемента.Видимость = Истина;

    РезультатФункции.Элемент = ГП_РаботаСФормамиКлиентСервер.СоздатьПолеФормы(ИмяСоздаваемогоЭлемента, ПараметрыЭлемента, ЭтотОбъект,
            "ГруппаСлева", "ВидОплаты");

    Возврат РезультатФункции;
КонецФункции

// Используется для указания что документ может быть использован при передаче в ОФД
// Возвращаемое значение:
//  - Структура
&НаСервере
Функция ГП_СоздатьПолеФлагаОплатаОтПокупателяФизЛицаНаСервере()
    РезультатФункции = Новый Структура("Элемент");

    НаименованиеСоздаваемогоЭлемента = "ГП_ОплатаОтПокупателяФизЛица";

    // Проверка наличия поля формы
    Если ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(ЭтотОбъект.Элементы, НаименованиеСоздаваемогоЭлемента) Тогда
        РезультатФункции.Элемент = ЭтотОбъект.Элементы[НаименованиеСоздаваемогоЭлемента];

        Возврат РезультатФункции; // Элемент уже существует
    КонецЕсли;

    РезультатФункции.Элемент = ГП_РаботаСФормамиКлиентСервер.СоздатьПолеФлажка(НаименованиеСоздаваемогоЭлемента,
            Новый Структура("Договор"), ЭтотОбъект, "ГруппаСправа", "ГруппаНастройкиРаспределения");
    РезультатФункции.Элемент.ПутьКДанным = СтрШаблон("Объект.%1", НаименованиеСоздаваемогоЭлемента);
    РезультатФункции.Элемент.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Право;
    РезультатФункции.Элемент.УстановитьДействие("ПриИзменении", НаименованиеСоздаваемогоЭлемента + "ПриИзменении");

    Возврат РезультатФункции;
КонецФункции

// Гарант+ Килипенко 21.03.2025 [F00236141] Приоритетное погашение долга закрытых л/с ++ {
//
// Возвращаемое значение:
//  - Структура
&НаСервере
Функция ГП_СоздатьДополнительныеСлужебныеРеквизитыФормыНаСервере()
    РезультатФункции = Новый Структура("Реквизиты", Новый Структура);

    НаименованиеСоздаваемогоРеквизита = "ГП_ДополнительныеПараметрыЗаполнения";

    // Проверка наличия поля формы
    Если ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(ЭтотОбъект, НаименованиеСоздаваемогоРеквизита) Тогда
        РезультатФункции.Реквизиты.Вставить(НаименованиеСоздаваемогоРеквизита, ЭтотОбъект[НаименованиеСоздаваемогоРеквизита]);

        Возврат РезультатФункции; // Элемент уже существует
    КонецЕсли;

    ТипРеквизита = Новый ОписаниеТипов;
    НовыйРеквизитФормы = Новый РеквизитФормы(НаименованиеСоздаваемогоРеквизита, ТипРеквизита);
    ЭтотОбъект.ИзменитьРеквизиты(ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(НовыйРеквизитФормы));
    РезультатФункции.Реквизиты.Вставить(НаименованиеСоздаваемогоРеквизита, НовыйРеквизитФормы);

    // Инициализация значений
    ЭтотОбъект[НаименованиеСоздаваемогоРеквизита] = ГП_НовыйСтруктураДополнительныхПараметров();

    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 21.03.2025 [F00236141] Приоритетное погашение долга закрытых л/с -- }

&НаСервере
Процедура ГП_СоздатьДополнительныеЭлементыНаСервере()
    ГП_СоздатьДополнительныеСлужебныеРеквизитыФормыНаСервере();
    ГП_СоздатьПолеКонтрагентНаСервере();
    ГП_СоздатьПолеФлагаОплатаОтПокупателяФизЛицаНаСервере();
КонецПроцедуры

&НаСервере
Процедура ГП_НастроитьВидимостьЭлементовФормыНаСервере()
    ЭтотОбъект.Элементы.ВидОплаты.Видимость = Ложь;

    ГП_ОбновитьОформлениеПоляОплатаОтПокупателяФизЛицаНаСервере();
КонецПроцедуры

&НаСервере
Процедура ГП_ОбновитьОформлениеПоляОплатаОтПокупателяФизЛицаНаСервере()
    Если ЭтотОбъект.Объект.ГП_ОплатаОтПокупателяФизЛица Тогда
        ЭтотОбъект.Элементы.ГП_ОплатаОтПокупателяФизЛица.ЦветТекстаЗаголовка = ЦветаСтиля.ЦветОсобогоТекста;
    Иначе
        ЭтотОбъект.Элементы.ГП_ОплатаОтПокупателяФизЛица.ЦветТекстаЗаголовка = ЦветаСтиля.ЦветТекстаПоля;
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // НастройкиФормы

#КонецОбласти // СлужебныеПроцедурыИФункции
// Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления -- }
