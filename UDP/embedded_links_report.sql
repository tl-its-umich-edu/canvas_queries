-- BigQuery SQL script
-- Adapted from the PSU reporting script:
-- https://gitlab.com/unizin-community/unizin-data-platform/consortium-projects/psu/links-datamart


-- main function for parsing out urls
-- uses javascript's cheerio library linked ot from our gs bucket
-- https://github.com/cheeriojs/cheerio
-- public version of library available from httparchive
CREATE TEMP FUNCTION
  extractURLsWithContext(html STRING)
  RETURNS ARRAY<STRUCT<url STRING, context STRING, wordCount INT, charCount INT, scheme STRING, host STRING, path STRING, queryString STRING, fileExtension STRING, usage STRING, tag STRING, attribute STRING, classes STRING, isSafeLink BOOLEAN, occurrenceNumber INT>>
  LANGUAGE js
  OPTIONS (
    library=["gs://udp-umich-prod-misc/links-datamart/cheerio.js", "gs://udp-umich-prod-misc/links-datamart/uri.js"]
  )
AS """
  try {
    var $ = cheerio.load(html || '');
    var linksInfo = [];
    // select which html tag and attributes to extract when parsing
    // also assign 
    var selectors = [
      {selector: 'link[href], a[href]', attribute: 'href', usage: 'hyperlink'},
      {selector: 'img[src], image > source[src]', attribute: 'src', usage: 'image'},
      {selector: 'video[src], video > source[src]', attribute: 'src', usage: 'video'},
      {selector: 'audio[src], audio > source[src]', attribute: 'src', usage: 'audio'},
      {selector: 'iframe[src], embed[src]', attribute: 'src', usage: 'embed'},
      {selector: 'object[data]', attribute: 'data', usage: 'embed'}, 
      {selector: 'script[src]', attribute: 'src', usage: 'script'},
      {selector: 'link[href][rel="stylesheet"]', attribute: 'href', usage: 'stylesheet'},
      {selector: 'area[href]', attribute: 'href', usage: 'image_map_link'}, 
      {selector: 'form[action]', attribute: 'action', usage: 'form_submission'}, 
      {selector: 'meta[http-equiv="refresh"]', attribute: 'http-equiv', usage: 'automatic_redirection'}
    ];
    
    var urlIndex = 0;

    selectors.forEach(function(item) {
      $(item.selector).each(function() {
        var url = $(this).attr(item.attribute) || '';
        var context = $(this).prop('outerHTML');

        var link_text = $(this).text(); // Extracts the text content from the element
        var words = link_text.trim().split(/\\s+/); // Splits the text into words based on whitespace
        var wordCount = words.length; // Counts the words
        var charCount = link_text.length; // Counts the characters in the trimmed text

        urlIndex++;
        var classes = $(this).attr('class') || '';
        var originalUrl = url;
        if (!url) return; // Skip if no URL is found

        var tag = $(this).prop('tagName').toLowerCase(); // Get the tag name
        var attribute = item.attribute; // Get the attribute used
        var usage = item.usage;
        var isSafeLink = false;
        
        // Decode SafeLinks
        var safeLinkPattern = /https:\\/\\/.*\\.safelinks\\.protection\\.outlook\\.com\\/.*\\?url=([^&]+)/;
        var match = url.match(safeLinkPattern);
        if (match && match[1]) {
          url = decodeURIComponent(match[1]);
          isSafeLink = true;
        }

        // Additional url clean-up
        url = url.replace(/^\\\\"|\\\\"$/g, ''); // remove escaped quotes around urls
        url = url.replace(/%24/g, '$'); // replace encoded $
        url = url.replace(/(%20)+$/, ''); // remove encoded spaces at the end of urls
        classes = classes.replace(/\\\\"/g, "");

        try {
            var uri = new URI(url);
            // Extracting url components using URI.js
            var scheme = uri.scheme(); // e.g., 'http'
            var host = uri.hostname(); // e.g., 'example.com'
            var path = uri.path(); // e.g., '/path/to/resource'
            var queryString = uri.query(); // e.g., 'key=value&anotherKey=anotherValue'
            var matchResult = path.match(/\\.([a-zA-Z0-9]{2,4})$/);
            var fileExtension = "";
            if (scheme !== "mailto" && matchResult) {
              fileExtension = matchResult[1].toLowerCase();
            }
        } catch (e) {
            console.error("Error parsing URI: " + url + " - " + e.message);
            scheme = 'error';
        };

        linksInfo.push({
          url: url,
          context: context,
          wordCount: wordCount,
          charCount: charCount,
          scheme: scheme,
          host: host,
          path: path,
          queryString: queryString,
          fileExtension: fileExtension,
          usage: usage,
          tag: tag,
          attribute: attribute,
          classes: classes,
          isSafeLink: isSafeLink,
          occurrenceNumber: urlIndex
        });
      });
    });

    return linksInfo;
  } catch (e) {
    return [{url: 'Error parsing HTML: ' + e.message, context: context ? [context] : ['not available'], tag: ['error']}];
  }
""";

WITH combined_content AS (
-- wiki pages (join for course_offering_id)
  SELECT
  wiki_page_id AS content_id,
  'wiki_page' AS content_type,
  body as content,
  course_offering_id,
  ewp.title AS content_name,
  status,
  ewp.updated_date
  FROM `context_store_entity.wiki_page` as ewp
    LEFT JOIN `context_store_entity.wiki` as ew
    ON ew.wiki_id = ewp.wiki_id

UNION ALL
-- discussion topics
SELECT
  discussion_id AS content_id,
  'discussion' AS content_type,
  body as context,
  course_offering_id,
  title AS content_name,
  status,
  updated_date
FROM
  `context_store_entity.discussion`

UNION ALL
-- learner activity (assignments)
SELECT
  learner_activity_id AS content_id,
  'learner_activity' AS content_type,
  description as context,
  course_offering_id,
  title AS content_name,
  status,
  updated_date
FROM
  `context_store_entity.learner_activity`

UNION ALL
-- modules
SELECT
  module_item_id AS content_id,
  'module_item' AS content_type,
  url as context,
  course_offering_id,
  title AS content_name,
  status,
  updated_date
FROM
  `context_store_entity.module_item`

UNION ALL
-- quizzes
SELECT
  quiz_id AS content_id,
  'quiz' AS content_type,
  description as context,
  course_offering_id,
  title AS content_name,
  status,
  updated_date
FROM
  `context_store_entity.quiz`

UNION ALL
-- quiz questions (join for course_offering_id)
SELECT
  quiz_item_id AS content_id,
  'quiz_item' AS content_type,
  body as context,
  course_offering_id,
  name AS content_name,
  eqi.status,
  eqi.updated_date
  FROM
    context_store_entity.quiz_item as eqi
  LEFT JOIN context_store_entity.quiz as eq
    ON eq.quiz_id = eqi.quiz_id

UNION ALL
-- syllabus content
SELECT
  course_offering_id AS content_id,
  'syllabus' AS content_type,
  syllabus_content as context,
  course_offering_id,
  title AS content_name,
  le_status AS status,
  null AS updated_date
FROM
  `context_store_entity.course_offering`

),

-- remove undesirables from combined 
-- remove undesirables from combined content
filtered_content AS (
  SELECT c.*, cok.lms_ext_id as canvas_course_id
  FROM combined_content c, 
  context_store_entity.course_offering co, 
  context_store_entity.academic_term t, 
  context_store_keymap.course_offering cok
  WHERE c.course_offering_id is not null
  and c.course_offering_id = co.course_offering_id
  and co.academic_term_id = t.academic_term_id
  and co.course_offering_id = cok.id
  and t.name='Winter 2025'
  and co.le_status ='available'
  --LIMIT 1000 -- Note with limit you may get no results if no urls to extract in sampled content
),

-- call cheerio function to extract urls from content
extracted_urls AS (
  SELECT
    canvas_course_id,
    content_id,
    content_type,
    course_offering_id,
    content_name,
    extractURLsWithContext(content) AS linksInfo,
    status,
    updated_date
  FROM filtered_content
),

-- unnest array returned from cheerio
unnested_urls AS (
  SELECT
    canvas_course_id,
    content_id,
    content_type,
    course_offering_id,
    content_name,
    (status IN ('active', 'available', 'published', 'post delayed')) AS isActive,
    updated_date,
    linkInfo.url AS url,
    linkInfo.context AS context,
    linkInfo.wordCount AS wordCount,
    linkInfo.charCount AS charCount,
    linkInfo.scheme AS scheme,
    linkInfo.host AS host,
    linkInfo.path AS path,
    linkInfo.queryString AS queryString,
    linkInfo.fileExtension AS fileExtension,
    linkInfo.usage AS usage,
    linkInfo.tag AS tag,
    linkInfo.attribute AS attribute,
    linkInfo.classes AS classes,
    linkInfo.isSafeLink AS isSafeLink,
    linkInfo.occurrenceNumber AS occurrence
  FROM extracted_urls,
  UNNEST(linksInfo) AS linkInfo
),

classified_urls AS (
  SELECT
    *,
    (
      CASE
        WHEN REGEXP_CONTAINS(url, r'\.instructure\.com/api/v1') THEN TRUE
        WHEN REGEXP_CONTAINS(url, r'/courses/\d+/') THEN TRUE
        WHEN REGEXP_CONTAINS(url, r'/modules/\d+/') THEN TRUE
        WHEN REGEXP_CONTAINS(url, r'/assignments/\d+/') THEN TRUE
        WHEN REGEXP_CONTAINS(url, r'/discussion_topics/\d+/') THEN TRUE
        WHEN REGEXP_CONTAINS(url, r'/quizzes/\d+/') THEN TRUE
        WHEN REGEXP_CONTAINS(url, r'/announcements/\d+/') THEN TRUE
        WHEN REGEXP_CONTAINS(url, r'\$CANVAS_OBJECT_REFERENCE\$') THEN TRUE
        ELSE FALSE
      END
    ) AS isCanvas
  FROM unnested_urls
)

--select content_type, count(*)
--FROM classified_urls
--group by content_type

-- Final SELECT for insert into unified_links
SELECT     
  ROW_NUMBER() OVER () AS link_id,
  canvas_course_id,
  content_type,
  content_id,
  content_name,
  course_offering_id,
  url,
  context,
  wordCount,
  charCount,
  usage,
  scheme,
  host,
  path,
  queryString,
  fileExtension,
  tag,
  attribute,
  classes,
  isSafeLink,
  isCanvas,
  isActive,
  FALSE AS isShortner,  -- Explicit default value for isShortner
  occurrence,
  updated_date
  FROM classified_urls
  where 
  url like 'https://www.mivideo.it.umich.edu/playlist/%' 
  or url like 'https://www.youtube.com/watch?%'
  or url like 'https://youtu.be/%'

