select
	id,
	title,
	locale,
	revision,
	content_type,
	required_clue_plus,
	created_at,
	updated_at,
	published_date
from
	import.airbyte_contentful_entries
where content_type = 'appArticle';