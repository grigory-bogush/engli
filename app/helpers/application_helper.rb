module ApplicationHelper

  # Format date like: Tuesday 30 Apr 2019
  def date_formatter(date)
    date.strftime('%A %d %b %Y')
  end

  def check_votes_for_email(phrase)
    if phrase.weighted_score / 5 > 0 && phrase.weighted_score % 5 == 0
      ApplicationMailer.with(user: phrase.user, phrase: phrase)
      .notify_five_upvotes.deliver_later
    end
  end

  # New vote. Add +4 carma to author, +1 to author
  def new_vote(vote, votable, voter)
    vote == 'up' ? votable.upvote_by(voter) : votable.downvote_by(voter)
    change_carma(vote, votable, voter, ex_up: 2, ex_down: -1, ph_up: 4, ph_down: -2, usr: 1)
    flash[:notice] = 'You\'ve undone your vote.'
  end

  # Change vote. Change carma
  def change_vote(vote, votable, voter)
    vote == 'up' ? votable.upvote_by(voter) : votable.downvote_by(voter)
    change_carma(vote, votable, voter, ex_up: 3, ex_down: -3, ph_up: 6, ph_down: -6, usr: 0)
    flash[:notice] = 'You\'ve changed your vote.'
  end

  # Undo vote. Subtract carma
  def undo_vote(vote, votable, voter)
    votable.unvote_by voter
    change_carma(vote, votable, voter, ex_up: -2, ex_down: 1, ph_up: -4, ph_down: 2, usr: -1)
    flash[:notice] = 'Thank you for your vote.'
  end

  private

  # Implementation method for carma
  def change_carma(vote, votable, voter, vals)
    author = votable.user
    author_carma = author.carma


    author_carma += if votable.class.name == 'Example'
                      vote == 'up' ? vals[:ex_up] : vals[:ex_down]
                    else # Phrase
                      vote == 'up' ? vals[:ph_up] : vals[:ph_down]
                    end

    author.update_attribute('carma', author_carma)

    voter.update_attribute('carma', voter.carma + vals[:usr]) if vals[:usr] != 0
  end
end
