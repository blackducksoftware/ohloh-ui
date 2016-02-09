$(document).ready ->
  $('#today_total_feedback').circliful()
  $('#today_more_info').circliful()
  $('#weekly_total_feedback').circliful()
  $('#weekly_more_info').circliful()
  $.ajax
    url: '/admin/feedbacks/dashboard_stats'
    type: 'GET'
    dataType: 'json'
    success: (data) ->
      weeklyData = data.stats_hash.weekly_rating
      todayData = data.stats_hash.today_rating

      weeklyDonutData = [
        {
          value: weeklyData.five_rating
          color: '#A13D92'
          highlight: '#A13D92'
          label: 'Extremely Helpful'
        }
        {
          value: weeklyData.four_rating
          color: '#0074d9'
          highlight: '#0074d9'
          label: 'Very Helpful'
        }
        {
          value: weeklyData.three_rating
          color: '#39cccc'
          highlight: '#39cccc'
          label: 'Somewhat Helpful'
        }
        {
          value: weeklyData.two_rating
          color: '#17B91A'
          highlight: '#17B91A'
          label: 'Slightly Helpful'
        }
        {
          value: weeklyData.one_rating
          color: '#A09A58'
          highlight: '#A09A58'
          label: 'Not Really Helpful'
        }
      ]

      emptyDonutData = [
        {
          value: 1e-10
          color: '#333333'
        }
      ]

      todayDonutData = [
        {
          value: todayData.five_rating
          color: '#A13D92'
          highlight: '#A13D92'
          label: 'Extremely Helpful'
        }
        {
          value: todayData.four_rating
          color: '#0074d9'
          highlight: '#0074d9'
          label: 'Very Helpful'
        }
        {
          value: todayData.three_rating
          color: '#39cccc'
          highlight: '#39cccc'
          label: 'Somewhat Helpful'
        }
        {
          value: todayData.two_rating
          color: '#17B91A'
          highlight: '#17B91A'
          label: 'Slightly Helpful'
        }
        {
          value: todayData.one_rating
          color: '#A09A58'
          highlight: '#A09A58'
          label: 'Not Really Helpful'
        }
      ]

      options = {
        responsive: true
        tooltipFontSize: 10
        tooltipTitleFontStyle: 'bold'
        tooltipFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif"
        tooltipTemplate: "<%if (label){%><%=label%>: <%}%><%= value %>%"
        percentageInnerCutout: 50
      }


      todayDataValues = Object.keys(todayData).map (key) ->
        todayData[key]

      weeklyDataValues = Object.keys(weeklyData).map (key) ->
        weeklyData[key]

      zeroTest = (element) ->
        element == 0

      if todayDataValues.every(zeroTest)
        todayDonutData = emptyDonutData
        $('ul#today_rating_list').html('<li> <span> No Ratings to display </span> </li>')

      if weeklyDataValues.every(zeroTest)
        weeklyDonutData = emptyDonutData
        $('ul#today_rating_list').html('<li> Oops! No Ratings</li>')

      weekly_donut_chart = $('#weekly_rating')[0].getContext('2d')
      today_donut_chart = $('#today_rating')[0].getContext('2d')

      window.myDoughnut = new Chart(weekly_donut_chart).Doughnut(weeklyDonutData, options)
      window.myDoughnut = new Chart(today_donut_chart).Doughnut(todayDonutData, options)
