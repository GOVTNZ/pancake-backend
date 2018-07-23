# frozen_string_literal: true

class CouncilPolicy < ApplicationPolicy
  def create?
    dia?
  end

  def update?
    dia?
  end

  def destroy?
    dia? && !record.rebate_forms.size.positive?
  end

  class Scope < Scope
    def resolve
      if user.present?
        scope.all
      else
        scope.none
      end
    end
  end
end
