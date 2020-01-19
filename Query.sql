select * from view_companiesYetToFillEmployees
select * from view_workshopsSeatLeft
select * from view_conferencesSeatsLeft
select * from view_reservationOnConferenceToDelete
select * from view_companiesYetToFillEmployees
select * from view_upcomingWorkshops

--x (top x)
select * from function_topIndividualClients(1)
select * from function_topCompaniesByTickets (1)
select * from function_topCompaniesByReservations (1)

--reservationID
/*select * from function_returnNormalTicketCost (1)
select * from function_returnStudentTicketCost (1)
select * from function_returnReservationCost(1)*/
select * from function_generateCompanyInvoice (1)
select * from function_generateIndividualInvoice (1)
select * from function_reservationSummary (1)

--ClientID (companyID)
select * from function_showEmployees (42)
--clientID
select * from function_showUnpaidReservations (1)

--WorkshopDictionaryID
select * from function_returnValueOfWorkshop (1)
--workshopID
select * from function_participantsOfWorkshop (1)

--confID, date
--select * from function_returnConferenceDay (1)
--confDayID
select * from function_participantsOfDayConference (1)
--confID
select * from function_participantListForConference (1)
select * from function_showFreeSeatsForConference (1)
select * from function_workshopsDuringConference (1)

--confID, startDate, discount
exec procedure_addPriceThreshold
exec procedure_deletePriceThreshold