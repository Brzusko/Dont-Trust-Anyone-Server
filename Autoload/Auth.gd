extends Node

const CREDENTIALS_FIELDS: Array = [
	"pn"
];

func are_credentials_valid(credentials: Dictionary):
	return credentials.has_all(CREDENTIALS_FIELDS);
