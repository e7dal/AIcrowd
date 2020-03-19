module ChallengesHelper
  def participant_invitation(email:)
    participant = Participant.find_by(email: email)
    if participant.present?
      return link_to participant.name, participant_path(participant)
    else
      return 'No AIcrowd account'
    end
  end

  def status_dropdown_helper(builder:)
    challenge = builder.object
    statuses  = Challenge.statuses.hash
    statuses  = statuses.except(:running, :completed, :terminated) if challenge.challenge_rounds.none? || challenge.dataset_files.none?
    builder.select(:status, statuses.map { |k, v| [v.humanize, k] }, {}, { class: "form-control", required: true })
  end

  def required_terms_or_rules_path(challenge)
    if !policy(challenge).has_accepted_participation_terms?
      [challenge, ParticipationTerms.current_terms]
    elsif !policy(challenge).has_accepted_challenge_rules?
      [challenge, challenge.current_challenge_rules]
    end
  end

  def challenge_remaining_text(challenge, challenge_round)
    case challenge.status
    when :running, :perpetual
      if remaining_time_in_days(challenge_round) >= 2
        "#{pluralize(remaining_time_in_days(challenge_round), 'day')} left"
      elsif remaining_time_in_hours(challenge_round) > 0
        "#{pluralize(remaining_time_in_hours(challenge_round), 'hour')} left &middot; Ending #{ending_dttm(challenge_round)}"
      elsif remaining_time_in_seconds(challenge_round) > 0
        "Less than 1 hour left &middot; Ending #{ending_dttm(challenge_round)}"
      else
        "Completed" # display for perpetual challenges
      end
    when :draft
      "Draft"
    when :completed
      "Completed"
    when :starting_soon
      "Starting soon"
    end
  end

  def challenge_stat_count(challenge, stat_type)
    case stat_type
    when 'submission'
      formatted_count(challenge.submissions_count)
    when 'view'
      formatted_count(challenge.page_views)
    when 'participant'
      formatted_count(challenge.challenge_participants.size)
    when 'vote'
      formatted_count(challenge.vote_count)
    end
  end

  def filter_message(status, category, prize)
    text  = "Filter challenges "
    text += "[from #{category[:category_names].join(', ').humanize} category] " if category.present?
    text += "[with status #{status.humanize}] " if status.present?
    text += "[prizes in form of #{prize[:prize_type].join(', ').humanize}]" if prize.present?
    text
  end

  def check_selected_category(category, params)
    return false unless params[:category].present?
    params[:category].dig(:category_names).include?(category.name)
  end

  def check_selected_prize(prize, params)
    return false unless params[:prize].present?
    params[:prize].dig(:prize_type).include?(prize.to_s)
  end

  def select_option(challenge)
    options_from_collection_for_select(Category.all, :name, :name, { selected: challenge.categories.pluck(:name) })
  end

  private

  def remaining_time_in_hours(challenge_round)
    (remaining_time_in_seconds(challenge_round) / (60 * 60)).floor
  end

  def remaining_time_in_days(challenge_round)
    (remaining_time_in_seconds(challenge_round) / (60 * 60 * 24)).floor
  end

  def remaining_time_in_seconds(challenge_round)
    return 0 if challenge_round.nil? || challenge_round.end_dttm.nil?

    seconds = challenge_round.end_dttm - Time.current
    seconds = 0 if seconds.nil? || seconds < 0
    return seconds
  end

  def ending_dttm(challenge_round)
    return nil if challenge_round.nil?

    challenge_round.end_dttm.strftime("%d %b %H:%M UTC")
  end

  def formatted_count(counter)
    if counter > 10000
      "#{format('%.1f', counter / 1000.0).chomp('.0')}k"
    else
      counter
    end
  end

  def resources_link(challenge)
    if challenge.clef_task.present?
      clef_task_task_dataset_files_path(challenge.clef_task, challenge_id: challenge.id)
    else
      challenge_dataset_files_path(challenge)
    end
  end

  def participants_link(challenge)
    if challenge.clef_task.present?
      clef_task_challenge_path(challenge)
    else
      challenge_participant_challenges_path(challenge)
    end
  end
end
