RaceDay API Endpoint Plan

Purpose

This document defines the planned API endpoints for the RaceDay event management system. The API will support authentication, user profiles, events, event categories, event enrolments, and participant results.

The system has two main roles:

- Organiser – manages events, categories, enrolments and results.
- Participant – creates an account, browses events, enrols in event categories and views personal results.

API Endpoint Table

HTTP Method| Route| Description| Role Required| Request Body| Expected Response
POST| "/api/auth/register"| Creates a new Participant account.| Public| "{ firstName, lastName, email, password }"| 201 Created – account created. 400 Bad Request – invalid details. 409 Conflict – email already exists.
POST| "/api/auth/login"| Authenticates a registered user and returns an access token.| Public| "{ email, password }"| 200 OK – login successful. 401 Unauthorized – invalid credentials.
GET| "/api/profile"| Retrieves the profile of the currently logged-in user.| Organiser / Participant| None| 200 OK – profile returned. 401 Unauthorized – user is not authenticated.
PUT| "/api/profile"| Updates the currently logged-in user's profile information.| Organiser / Participant| "{ firstName, lastName, email }"| 200 OK – profile updated. 400 Bad Request – invalid details. 401 Unauthorized – not authenticated.
GET| "/api/events"| Returns a list of available RaceDay events.| Public| None| 200 OK – events returned.
GET| "/api/events/{id}"| Returns details for a specific event.| Public| None| 200 OK – event returned. 404 Not Found – event does not exist.
POST| "/api/events"| Creates a new RaceDay event.| Organiser| "{ name, description, date, location }"| 201 Created – event created. 400 Bad Request – invalid details. 401 Unauthorized – not authenticated. 403 Forbidden – user is not an Organiser.
PUT| "/api/events/{id}"| Updates an existing event.| Organiser| "{ name, description, date, location }"| 200 OK – event updated. 400 Bad Request – invalid details. 404 Not Found – event does not exist. 403 Forbidden – insufficient permissions.
DELETE| "/api/events/{id}"| Deletes an existing event.| Organiser| None| 204 No Content – event deleted. 404 Not Found – event does not exist. 403 Forbidden – insufficient permissions.
GET| "/api/events/{eventId}/categories"| Retrieves all categories belonging to a specific event.| Public| None| 200 OK – categories returned. 404 Not Found – event does not exist.
POST| "/api/events/{eventId}/categories"| Creates a category for a specific event.| Organiser| "{ name, distance, entryFee }"| 201 Created – category created. 400 Bad Request – invalid details. 404 Not Found – event does not exist.
PUT| "/api/categories/{id}"| Updates an existing event category.| Organiser| "{ name, distance, entryFee }"| 200 OK – category updated. 400 Bad Request – invalid details. 404 Not Found – category does not exist.
DELETE| "/api/categories/{id}"| Deletes an existing event category.| Organiser| None| 204 No Content – category deleted. 404 Not Found – category does not exist.
POST| "/api/events/{eventId}/enrolments"| Enrols the logged-in Participant in an event category.| Participant| "{ categoryId }"| 201 Created – enrolment created. 400 Bad Request – invalid category. 404 Not Found – event or category does not exist. 409 Conflict – Participant is already enrolled.
GET| "/api/enrolments"| Retrieves the logged-in Participant's event enrolments.| Participant| None| 200 OK – enrolments returned. 401 Unauthorized – not authenticated.
GET| "/api/events/{eventId}/enrolments"| Retrieves all Participants enrolled in a specific event.| Organiser| None| 200 OK – enrolments returned. 404 Not Found – event does not exist. 403 Forbidden – insufficient permissions.
DELETE| "/api/enrolments/{id}"| Cancels an existing Participant enrolment.| Participant| None| 204 No Content – enrolment cancelled. 404 Not Found – enrolment does not exist.
POST| "/api/events/{eventId}/results"| Records a Participant's result for an event.| Organiser| "{ enrolmentId, finishTime, position }"| 201 Created – result recorded. 400 Bad Request – invalid result. 404 Not Found – event or enrolment does not exist.
GET| "/api/events/{eventId}/results"| Retrieves all results for a specific event.| Organiser| None| 200 OK – results returned. 404 Not Found – event does not exist.
GET| "/api/results"| Retrieves the logged-in Participant's personal results history.| Participant| None| 200 OK – personal results returned. 401 Unauthorized – not authenticated.
GET| "/api/results/{id}"| Retrieves details of a specific result.| Participant / Organiser| None| 200 OK – result returned. 404 Not Found – result does not exist. 403 Forbidden – user cannot access the result.