﻿// Гарант+ Килипенко 23.09.2024 [F00227727] Доработать заполнение документа начисление по приборам учета (выбор услуги) ++
#Область ПрограммныйИнтерфейс

Функция ОткрытьФормуВыбораУслуги(Знач ПараметрыФормы, Знач ОписаниеОповещения, Знач Владелец) Экспорт
    РезультатФункции = ОткрытьФорму("Справочник.КВП_Услуги.ФормаВыбора",
            ПараметрыФормы,
            Владелец, , , ,
            ОписаниеОповещения,
            РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
    Возврат РезультатФункции;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс
// Гарант+ Килипенко 23.09.2024 [F00227727] Доработать заполнение документа начисление по приборам учета (выбор услуги) --
