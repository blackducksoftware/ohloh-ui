"""Helper methods to help making feature vectors."""

from collections import Counter
import setup
import numpy as np
import string as sr
import ast


def map_index(file_path):
    """Read the contents of the file and map with index as value.

    Args:
        file_path (str) - file path
    Returns:
        dictionary with values are indices of the keys on the file

    """
    f = open(file_path, 'r')
    lines = f.readlines()
    num_of_lines = len(lines)
    tuple_lst = [(lines[index].strip(), index)
                 for index in range(num_of_lines)]
    result_map = dict(iter(tuple_lst))

    return result_map


def map_tuple(file_path):
    """Read the contents of the file and map with the 2nd value of the tuple.

    Args:
        file_path (str) - file path. Contains tuples
    Returns:
        dictionary with values are 2nd values of the tuples.

    """
    f = open(file_path, 'r')
    lines = f.readlines()
    num_of_lines = len(lines)
    tuple_lst = []

    for index in range(num_of_lines):
        line = lines[index].strip()
        tup = ast.literal_eval(line)
        tuple_lst.append(tup)

    result_map = dict(iter(tuple_lst))

    return result_map


def loader():
    """Load and process necessary files.

    It uses bag_of_words, domain_union and tail_union files
    to create dictionaries:
        -bag_of_words: (word, weight)
        -common_url_words: (url, index)
        -common_domains: (domain, index)
        -common_tails: (tail, index)
        -common_joins: (join, index)
    It gets the paths of these file from setup.py:

    """
    # map of bag of words:
    global bag_of_words
    bag_of_words = map_index(setup.bag_of_words)

    # map of common url words:
    global common_url_words
    common_url_words = map_index(setup.common_url_words)

    # map of common domain names:
    global common_domains
    common_domains = map_index(setup.common_domains)

    # map of domain tails:
    global common_tails
    common_tails = map_index(setup.common_tails)

    # map of join: domain.tail:
    global common_joins
    common_joins = map_index(setup.common_joins)


# Run the loader
loader()


# Helper functions to help parsing information:
def check_bow(string, sentence=False):
    """Check if the word/sentence contains spam words.

    Args:
        string: A word/sentece string.
        sentence: A boolean indicating if it's a sentence or not
                  default to False.
    Returns:
        res: 1 if contains spam words. 0 otherwise

    """
    if(sentence):
        words = string.strip()
        for word in words:
            res = check_bow(word)
            if(res != 0):
                return res
        return 0

    for word in bag_of_words:
        if(word in string):
            return bag_of_words[word]
    return 0


def string_parser(string):
    """Parse the word/sentence and find different character counts.

    Args:
        string: Word/Sentence string.
    Returns:
        list: A list of counts [letters, digits, white spaces, others].

    """
    char_count = Counter(string)
    letter_count = sum([char_count[char] for char in sr.ascii_lowercase])
    digit_count = sum([char_count[char] for char in sr.digits])
    white_space_count = sum([char_count[char] for char in sr.whitespace])
    other_count = len(string) - \
        (letter_count + digit_count + white_space_count)

    return [letter_count, digit_count, white_space_count, other_count]


def url_check(string):
    """Check if the string has any url.

    Args:
        string: The sentence/word string.
    Returns:
        result: 1 if url exists, 0 otherwise.

    """
    # href, www, http
    indicators = ['href', 'www', 'http']

    for indicator in indicators:
        if indicator in string:
            return 1
    return 0


def three_consecutive(string):
    """Check if the string has 3 consecutive characters.

    Args:
        string: The sentence/word string.
    Returns:
        result: 1 if such consecutive characters exists, 0 otherwise.

    """
    for i in range(len(string) - 2):
        match = string[i] == string[i+1] == string[i+2]
        if(match):
            return 1
    return 0


def process_domain(domain):
    """Map domain name parts to common domains and tails.

    First, it checks the common_domain index and add 1 on that index.
    Then, it checks the common_tail index and add 1 on that index.
    finally, it checks common_join index and add 1 on that index.

    There are three indices that for no domain/tail/join match.
    Args:
        domain: The domain part (a string) of the email.
    Returns:
        array: A numpy array of size
            number_of_domains + number_of_tails + number_of_joins + 3

    """
    domain_arr = np.zeros(len(common_domains) + 1)
    tail_arr = np.zeros(len(common_tails) + 1)
    join_arr = np.zeros(len(common_joins) + 1)

    domain_part = domain.split('.', 1)[0]
    # Note: had to include -1 for a email id with @yayoo with no tail
    tail_part = domain.split('.', 1)[-1]

    # Check Domain
    if(domain_part in common_domains):
        index = common_domains[domain_part]
        domain_arr[index] = 1
    else:
        domain_arr[-1] = 1

    # Check Tail
    if(tail_part in common_tails):
        index = common_tails[tail_part]
        tail_arr[index] = 1
    else:
        tail_arr[-1] = 1

    # Check Join
    if(domain in common_joins):
        index = common_joins[domain]
        join_arr[index] = 1
    else:
        join_arr[-1] = 1

    return np.concatenate([domain_arr, tail_arr, join_arr])


def create_matrix(query_result, marker):
    """Create numpy matrix from the query result.

    Args:
        -query_result (query result from db.cursor)
        -marker (integer indicating what class it is)
    Returns:
        numpy matrix of the feature vectors with last column is the labels

    """
    array_lst = []
    for line in query_result:
        # Get required info to parse the query
        account_id, email, login, commits_count, \
            contribution_count, posts_count, projects_used_count, \
            name, url, about = line

        # Call parser with these values to get the vector
        vector = parser(account_id, email, login, commits_count=commits_count,
                        contribution_count=contribution_count,
                        posts_count=posts_count,
                        projects_used_count=projects_used_count,
                        name=name, url=url, about=about)

        # Add the marker at the end of the vector
        tup = np.append(vector, marker)
        array_lst.append([tup])
    final_array = np.concatenate(array_lst)
    return final_array


def create_feature_vector(query_result):
    """Create numpy feature vector to from the query_result."""
    account_id, email, login, commits_count, \
        contribution_count, posts_count, projects_used_count, \
        name, url, about = query_result[0]  # since only one line

    # Call parser with these values to get the vector
    vector = parser(account_id, email, login, commits_count=commits_count,
                    contribution_count=contribution_count,
                    posts_count=posts_count,
                    projects_used_count=projects_used_count,
                    name=name, url=url, about=about)

    return vector


def process_url(url):
    """Process URL.

    Checks if the url has 'github', 'blog', 'wordpress', 'facebook', 'twitter',
    etc. to get more info about people. Similar to bag of words.

    Args:
        url (str) - the url
    Returns:
        numpy array to indicate whether the emails are there.

    """
    # smaller case url:
    small_url = url.lower()
    num_url_words = len(common_url_words)
    url_arr = np.zeros(num_url_words + 1)

    for word in common_url_words:
        if word in small_url:
            index = common_url_words[word]
            url_arr[index] = 1

    # Also add url length at the end:
    url_arr[-1] = len(url)

    return url_arr


def parser(account_id, email, login, commits_count=0, contribution_count=0,
           posts_count=0, projects_used_count=0, name='', url='', about=''):
    """Parse the data_point and transform it to a feature vector.

    Args:
        tup: A result entry from sql result for a user.
    Returns:
        parsed: A numpy array representing the feature vector.

    """
    # count_array = (commits_count, contribution_count,
    #                   posts_count, projects_used_count)
    commits_count = 0 if commits_count is None \
        else commits_count

    contribution_count = 0 if contribution_count is None \
        else contribution_count

    posts_count = 0 if posts_count is None \
        else posts_count

    projects_used_count = 0 if projects_used_count is None \
        else projects_used_count

    count_array = np.array([commits_count, contribution_count,
                            posts_count, projects_used_count])

    # parse name:
    name_lc = '' if name is None else name.lower()
    name_in_bag = check_bow(name_lc)
    name_counts = string_parser(name_lc)
    name_has_three = three_consecutive(name_lc)
    name_counts.extend([name_in_bag, name_has_three])

    parse_name_array = np.array(name_counts)

    # parse login:
    login_lc = '' if login is None else login.lower()
    login_in_bag = check_bow(login_lc)
    login_counts = string_parser(login_lc)
    login_has_three = three_consecutive(login_lc)
    login_counts.extend([login_in_bag, login_has_three])

    login_array = np.array(login_counts)

    # parse about: Avoiding counting three consequtives for now
    about_lc = '' if about is None else about.lower()
    about_in_bag = check_bow(about_lc, True)
    about_counts = string_parser(about_lc)
    about_has_url = url_check(about_lc)
    about_counts.extend([about_in_bag, about_has_url])

    about_array = np.array(about_counts)

    # parse URLs
    url = '' if url is None else url
    url_array = process_url(url)

    # parse local part of email_id. Treat it as a login_name
    local_part = email.split('@')[0]
    local_part_lc = local_part.lower()
    local_in_bag = check_bow(local_part_lc)
    local_counts = string_parser(local_part_lc)
    local_has_three = three_consecutive(local_part_lc)
    local_counts.extend([local_in_bag, local_has_three])

    local_part_array = np.array(local_counts)

    # domain part
    domain_part = email.split('@')[1]
    domain_part_array = process_domain(domain_part)

    array_lst = [count_array, parse_name_array, login_array, about_array,
                 url_array, local_part_array, domain_part_array]
    parsed = np.concatenate(array_lst)

    return parsed
