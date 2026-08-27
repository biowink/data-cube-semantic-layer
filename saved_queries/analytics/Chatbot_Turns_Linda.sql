SELECT
    CAST(turns.id AS integer) AS turn_id,
    turns.conversation_number,
    turns.previous_user_message,
    turns.previous_final_response,
    turns.user_message,
    CASE WHEN turns.user_message IN ('Are my cycles regular?',
                                    'Help me plan - when’s my period likely to arrive?',
                                    'What is my average period length?',
                                    'Help me plan. When might my next period arrive?',
                                    'What’s the typical length of my period?')
    THEN TRUE ELSE FALSE END AS is_conversation_starters,
    labels.intent AS intent_tag,
    turns.final_response,
    labels.outcome AS outcome_tag,
    -- context.tool_calls,
    grounding.tag AS grounding_tag,
    grounding.rationale
FROM der.chatbot_turns turns
LEFT JOIN der.chatbot_turn_languages lang
    ON turns.id = lang.id
LEFT JOIN der.chatbot_turn_labels labels
    ON turns.id = labels.turn_id
LEFT JOIN der.chatbot_turn_tool_context context
    ON turns.id = context.turn_id
LEFT JOIN der.chatbot_turn_grounding grounding
    ON turns.id = grounding.turn_id
WHERE user_message_language_code = 'en'
    AND final_response_language_code = 'en'
    AND labels.model_name = 'claude-sonnet-4-6'
    AND grounding.model_name = 'claude-sonnet-4-6'
    -- fill in the tag you want to see and uncomment the row before executing
    -- AND labels.intent = ''
    -- AND labels.outcome = ''
    -- AND grounding.tag = ''
ORDER BY CAST(turns.id AS integer), turns.conversation_number;