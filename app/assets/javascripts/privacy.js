var Privacy = {
    init: function(){
        status = $("input[type=radio][name='account[email_master]']:checked").val();
        $('#account_email_master_false').click(function(e){
            Privacy.toggleBoxes(false);
            $(this).next("span").addClass("email_opted_out");
            $(this).nextAll(':lt(4)').removeClass("email_opted_in");
        });

        $('#account_email_master_true').click(function(e){
            Privacy.toggleBoxes(true);
            $(this).next("span").addClass("email_opted_in");
            $(this).prevAll(':lt(2)').removeClass("email_opted_out");
        });

        $('#account_email_posts, #account_email_kudos').change(function(e){
            if($('#account_email_posts').val() == "true" || $('#account_email_kudos').val() == "true")
                $('#account_email_master_true').trigger('click');
        });

        //On Page Load trigger the appropriate click on the radio button
        $('#account_email_master_'+status).trigger('click');
    },

    toggleBoxes: function(true_or_false){
        var color = (true_or_false) ? "black" : "lightgray";
        if (true_or_false == false){
            $('#account_email_posts').val(true_or_false.toString());
            $('#account_email_kudos').val(true_or_false.toString());
        }
        $('#account_email_posts').css("color", color);
        $('#account_email_kudos').css("color", color);
        $('ul#email_status').css("color", color);
    }
}